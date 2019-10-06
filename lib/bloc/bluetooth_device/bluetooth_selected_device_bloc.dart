import 'dart:async';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oklok/helpers/bluetooth_lock_helpers.dart';
import '../bloc.dart';

class BluetoothSelectedDeviceBloc extends Bloc<BluetoothSelectedDeviceEvent, BluetoothSelectedDeviceState> {
  BluetoothBloc _bluetoothBloc;
  BluetoothDevice _bluetoothDevice;

  StreamSubscription<List<int>> _listenNotify;
  StreamSubscription<BluetoothDeviceState> _deviceState;

  BluetoothSelectedDeviceBloc(this._bluetoothBloc);

  set bluetoothDevice(BluetoothDevice value) {
    _bluetoothDevice = value;
  }

  set deviceKey(Uint8List key) {
    _deviceEncryptionKey = key;
  }

  BluetoothDevice get device => _bluetoothDevice;

  Uint8List _deviceEncryptionKey = Uint8List.fromList([12, 08, 13, 89, 63, 90, 35, 80, 45, 86, 26, 48, 40, 15, 51, 51]);

  @override
  BluetoothSelectedDeviceState get initialState => InitialSelectedBluetoothDeviceState();

  @override
  Stream<BluetoothSelectedDeviceState> mapEventToState(
    BluetoothSelectedDeviceEvent event,
  ) async* {
    if (event is ConnectToDevice) {
      yield (ConnectingToDevice());

      try {
        await this._bluetoothDevice.disconnect();
        await this._bluetoothDevice.connect(timeout: Duration(seconds: 3), autoConnect: false).timeout(Duration(seconds: 3), onTimeout: () {
          this._bluetoothDevice.disconnect();
          throw ('Failed to connect in time');
        });

        _deviceState?.cancel();
        _deviceState = this._bluetoothDevice.state.listen((BluetoothDeviceState state) {
          print('Device state: $state');
          dispatch(BluetoothDeviceStateChanged(state));
        });
      } catch (e) {
        print('Error :  $e');
        yield (InitialSelectedBluetoothDeviceState());
      }

      List<BluetoothService> services = await device.discoverServices();

      final BluetoothService service = services.lastWhere((BluetoothService s) => s.uuid.toString() == '0000fee7-0000-1000-8000-00805f9b34fb');
      final BluetoothCharacteristic write =
          service.characteristics.lastWhere((BluetoothCharacteristic c) => c.uuid.toString() == '000036f5-0000-1000-8000-00805f9b34fb');
      final BluetoothCharacteristic notify =
          service.characteristics.lastWhere((BluetoothCharacteristic c) => c.uuid.toString() == '000036f6-0000-1000-8000-00805f9b34fb');

      _listenNotify?.cancel();

      print('Notify listen available : ${_listenNotify ?? false}');

      await notify.setNotifyValue(true);
      print('is notify ${notify.isNotifying}');
      _listenNotify = notify.value.listen((data) {
        print('Response : $data');
        if (data.isNotEmpty) {
          dispatch(NotifyValueChanged(Uint8List.fromList(data)));
        }
      });

      yield (ConnectedToDevice(DeviceCommunicationProperties(service: service, notify: notify, write: write)));
    } else if (event is NotifyValueChanged) {
      ConnectedToDevice cState = (currentState as ConnectedToDevice);
      Uint8List decrypted = CommunicationCipher.decrypt(event.value, this._deviceEncryptionKey);

      print('Decrypted : $decrypted');

      if (cState.bluetoothEventCommunication.type == CommunicationType.token_acquisition) {
        int tokenLength = 4;
        int tokenStart = 3;

        Uint8List token = Uint8List.fromList(decrypted.getRange(tokenStart, tokenLength + tokenStart).toList());
        print('Token $token');
        yield (cState.update(bluetoothEventCommunication: cState.bluetoothEventCommunication.update(response: decrypted, token: token)));
      } else {
        yield (cState.update(bluetoothEventCommunication: cState.bluetoothEventCommunication.update(response: decrypted)));
      }
    } else if (event is WriteToDevice) {
      ConnectedToDevice cState = (currentState as ConnectedToDevice);

      cState.deviceCommunicationProperties.write.write(event.sender);

      yield (cState.update(bluetoothEventCommunication: cState.bluetoothEventCommunication.update(type: event.type, sender: event.sender)));
    } else if (event is BluetoothDeviceStateChanged) {
      if (event.state == BluetoothDeviceState.disconnected) {
        _deviceState?.cancel();
        _listenNotify?.cancel();
        yield (InitialSelectedBluetoothDeviceState());
      }
    } else if (event is DisconnectFromDevice) {
      this._bluetoothDevice.disconnect();
    }

    /* Event */
    else if (event is BluetoothDeviceUnlock) {
      ConnectedToDevice cState = (currentState as ConnectedToDevice);
      Uint8List encrypted = BluetoothCommandHelper.unlocking(this._deviceEncryptionKey, cState.bluetoothEventCommunication.token);
      dispatch(WriteToDevice(CommunicationType.unlocking, encrypted));
    } else if (event is BluetoothDeviceCheckPower) {
      ConnectedToDevice cState = (currentState as ConnectedToDevice);
      Uint8List encrypted = BluetoothCommandHelper.checkPower(this._deviceEncryptionKey, cState.bluetoothEventCommunication.token);
      dispatch(WriteToDevice(CommunicationType.check_power, encrypted));
    } else if (event is TokenAcquisition) {
      Uint8List encrypted = BluetoothCommandHelper.tokenAcquisition(this._deviceEncryptionKey);
      dispatch(WriteToDevice(CommunicationType.token_acquisition, encrypted));
    }
  }

  @override
  void dispose() {
    print('disposed');
    _listenNotify?.cancel();
    _deviceState?.cancel();
    super.dispose();
  }
}
