import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BluetoothState extends Equatable {
  BluetoothState([List props = const <dynamic>[]]) : super(props);
}

class InitialBluetoothState extends BluetoothState {}

class ScanningDevice extends BluetoothState {}

class ScanCompleted extends BluetoothState {
  final List<ScanResult> devices ;
  ScanCompleted(this.devices):super([devices]);
}
