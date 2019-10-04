import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_blue/flutter_blue.dart' as flutterBlue;
import '../bloc.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {

  flutterBlue.FlutterBlue _flutterBlue;
  List<flutterBlue.ScanResult> _deviceResults;
  bool _blError = false;
  
  StreamSubscription _streamSubscriptionBluetooth ;

  BluetoothBloc() {
    try {
      _flutterBlue = flutterBlue.FlutterBlue.instance;
    } catch (e) {
      _blError = true ;
    }
  }

  @override
  BluetoothState get initialState => InitialBluetoothState();

  @override
  Stream<BluetoothState> mapEventToState(
    BluetoothEvent event,
  ) async* {
    if(_blError) {
      return ;
    }
    if(event is StartScan) {
      _deviceResults = List<flutterBlue.ScanResult>(0).toList() ;

      yield(ScanningDevice());
      _streamSubscriptionBluetooth = this._flutterBlue.scan().listen((flutterBlue.ScanResult device) {
        int _index = _deviceResults.indexWhere((flutterBlue.ScanResult test) => test.device.id.id == device.device.id.id);
        if(_index == -1) {
          _deviceResults.add(device);
        }
        print(device);
      });
    } else if (event is StopScan) {
      _streamSubscriptionBluetooth.cancel();
      this._flutterBlue.stopScan();
      yield(ScanCompleted( _deviceResults));
    }
  }
}
