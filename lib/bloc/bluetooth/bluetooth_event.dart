import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BluetoothEvent extends Equatable {
  BluetoothEvent([List props = const <dynamic>[]]) : super(props);
}

class StartScan extends BluetoothEvent {}

class StopScan extends BluetoothEvent {}