import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BluetoothScanState extends Equatable {
  BluetoothScanState([List props = const <dynamic>[]]) : super(props);
}

class InitialBluetoothScanState extends BluetoothScanState {}

class ScanningDevice extends BluetoothScanState {
  final List<ScanResult> discoveredDevices;

  ScanningDevice(this.discoveredDevices) : super([discoveredDevices]);
}

class ScanCompleted extends BluetoothScanState {
  final List<ScanResult> discoveredDevices;
  final bool isConnecting;

  ScanCompleted(this.discoveredDevices, {bool connecting})
      : this.isConnecting = connecting ?? false,
        super([discoveredDevices]);

  ScanCompleted setConnectingStatus(bool status){
    return this._update(isConnecting: status);
  }

  ScanCompleted setDiscoveredDevice(List<ScanResult> discoveredDevices){
    return this._update(discoveredDevices: discoveredDevices);
  }

  ScanCompleted _update({bool isConnecting, List<ScanResult> discoveredDevices}){
    return ScanCompleted(
        discoveredDevices ?? this.discoveredDevices,
        connecting: isConnecting ?? this.isConnecting
    );
  }

}
