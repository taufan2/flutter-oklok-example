import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class BluetoothSelectedDeviceState extends Equatable {
  BluetoothSelectedDeviceState([List props = const <dynamic>[]]) : super(props);
}

class InitialSelectedBluetoothDeviceState extends BluetoothSelectedDeviceState {}

class ConnectingToDevice extends BluetoothSelectedDeviceState {}

class ConnectedToDevice extends BluetoothSelectedDeviceState {
  final DeviceCommunicationProperties deviceCommunicationProperties;
  final DeviceCommunicationMessages bluetoothEventCommunication;

  ConnectedToDevice(this.deviceCommunicationProperties, {bluetoothEventCommunication})
      : this.bluetoothEventCommunication = bluetoothEventCommunication ?? DeviceCommunicationMessages(),
        super([deviceCommunicationProperties, bluetoothEventCommunication]);

  ConnectedToDevice update({deviceCommunication, bluetoothEventCommunication}) {
    return ConnectedToDevice(deviceCommunication ?? this.deviceCommunicationProperties,
        bluetoothEventCommunication: bluetoothEventCommunication ?? this.bluetoothEventCommunication);
  }
}

/*
* Model
* */

class DeviceCommunicationProperties extends Equatable {
  final BluetoothService service;
  final BluetoothCharacteristic write;
  final BluetoothCharacteristic notify;

  DeviceCommunicationProperties({this.service, this.write, this.notify}) : super([service, write, notify]);
}

enum CommunicationType { connecting, check_power, token_acquisition, unlocking, locking }

class DeviceCommunicationMessages extends Equatable {
  final CommunicationType type;
  final Uint8List sender;
  final Uint8List response;
  final Uint8List token ;

  DeviceCommunicationMessages({type, sender, response, token})
      : this.type = type ?? CommunicationType.connecting,
        this.sender = sender ?? Uint8List(16),
        this.response = response ?? Uint8List(16),
        this.token = token ?? Uint8List(4),
        super([type, sender, response]);

  DeviceCommunicationMessages update({type, sender, response, token}) {
    return DeviceCommunicationMessages(type: type ?? this.type, sender: sender ?? this.sender, response: response ?? this.response, token: token ?? this.token);
  }
}
