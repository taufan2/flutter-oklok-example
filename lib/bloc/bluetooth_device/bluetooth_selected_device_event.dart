import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'bluetooth_selected_device_state.dart';

abstract class BluetoothSelectedDeviceEvent extends Equatable {
  BluetoothSelectedDeviceEvent([List props = const <dynamic>[]]) : super(props);
}

class ConnectToDevice extends BluetoothSelectedDeviceEvent {}
class DisconnectFromDevice extends BluetoothSelectedDeviceEvent {}

class NotifyValueChanged extends BluetoothSelectedDeviceEvent {
  final Uint8List value;

  NotifyValueChanged(this.value) : super([value]);
}

class WriteToDevice extends BluetoothSelectedDeviceEvent {
  final CommunicationType type;
  final Uint8List sender;

  WriteToDevice(this.type, this.sender);
}

class BluetoothDeviceStateChanged extends BluetoothSelectedDeviceEvent {
  final BluetoothDeviceState state ;

  BluetoothDeviceStateChanged(this.state) : super([state]);
}

class BluetoothDeviceUnlock extends BluetoothSelectedDeviceEvent {}
class BluetoothDeviceCheckPower extends BluetoothSelectedDeviceEvent {}
class TokenAcquisition extends BluetoothSelectedDeviceEvent {}