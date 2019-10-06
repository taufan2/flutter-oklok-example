import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../bloc.dart';

class BluetoothBloc extends Bloc<BluetoothScanEvent, BluetoothScanState> {

  FlutterBlue _flutterBlue = FlutterBlue.instance;
  List<ScanResult> _deviceResults = List();
  StreamSubscription _streamSubscriptionBluetooth ;

  BluetoothBloc(){
    this._flutterBlue.state.listen((BluetoothState state) {
      print('Bluetooth State : $state');
    });
  }

  FlutterBlue get flutterBlue => _flutterBlue;

  set streamSubscriptionBluetooth(StreamSubscription value) {
    _streamSubscriptionBluetooth = value;
  }

  @override
  BluetoothScanState get initialState => InitialBluetoothScanState();

  @override
  Stream<BluetoothScanState> mapEventToState(
    BluetoothScanEvent event,
  ) async* {
    if(event is StartScan) {
      yield(ScanningDevice(List<ScanResult>()));
    }

    else if (event is DeviceDiscovered) {
      List<ScanResult> _scanResults = List<ScanResult>();

      if (currentState is ScanningDevice) {
        _scanResults.addAll((currentState as ScanningDevice).discoveredDevices);
      }

      int _index = _scanResults.indexWhere((ScanResult test) =>
      test.device.id.id == event.scanResult.device.id.id);

      if (_index == -1) {
        _scanResults.add(event.scanResult);
      }

      _deviceResults = _scanResults ;

      yield(ScanningDevice(
          _deviceResults
      ));

    }

    else if (event is StopScan) {
      this._flutterBlue.stopScan();
      this._streamSubscriptionBluetooth.cancel();
      yield(ScanCompleted( _deviceResults));
    }
  }
}
