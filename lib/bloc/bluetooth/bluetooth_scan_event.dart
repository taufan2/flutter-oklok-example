import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BluetoothScanEvent extends Equatable {
  BluetoothScanEvent([List props = const <dynamic>[]]) : super(props);
}

class StartScan extends BluetoothScanEvent {}

class DeviceDiscovered extends BluetoothScanEvent {
  final ScanResult scanResult;

  DeviceDiscovered(this.scanResult) : super([scanResult]);
}

class StopScan extends BluetoothScanEvent {}