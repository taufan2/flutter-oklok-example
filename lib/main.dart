import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart' as flutterBlue;
import 'package:oklok/LockAPI.dart';
import 'package:oklok/bloc/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLE Padlock',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothBloc _bluetoothBloc;
  BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc;

  @override
  void initState() {
    super.initState();
    _bluetoothBloc = BluetoothBloc();
    _bluetoothSelectedDeviceBloc = BluetoothSelectedDeviceBloc(_bluetoothBloc);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<BluetoothBloc>(
            builder: (BuildContext context) => _bluetoothBloc,
          ),
          BlocProvider<BluetoothSelectedDeviceBloc>(
            builder: (BuildContext context) => _bluetoothSelectedDeviceBloc,
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text("Flutter Bluetooth"),
          ),
          body: ScanResultList(),
          bottomNavigationBar: ScanButtonView(),
        ));
  }
}

// ignore: must_be_immutable
class ScanButtonView extends StatelessWidget {
  BluetoothBloc _bluetoothBloc;

  void scan() {
    this._bluetoothBloc.streamSubscriptionBluetooth = _bluetoothBloc.flutterBlue.scan().listen((device) {
      print(device);
      _bluetoothBloc.dispatch(DeviceDiscovered(device));
    });
    _bluetoothBloc.dispatch(StartScan());
    Future.delayed(Duration(seconds: 3)).then((_){
      _bluetoothBloc.dispatch(StopScan());
    });
  }

  @override
  Widget build(BuildContext context) {
    this._bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);

    BluetoothBloc _bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    return BlocBuilder(
      bloc: _bluetoothBloc,
      builder: (BuildContext context, BluetoothScanState state) {
        if (state is ScanningDevice) {
          return RaisedButton(
            child: Text("Berhenti"),
            onPressed: () => _bluetoothBloc.dispatch(StopScan()),
          );
        } else {
          return RaisedButton(
            child: Text("Cari Perangkat"),
            onPressed: () => this.scan(),
          );
        }
      },
    );
  }
}

class ScanResultList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc = BlocProvider.of<BluetoothSelectedDeviceBloc>(context);
    BluetoothBloc _bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);

    return BlocBuilder<BluetoothBloc, BluetoothScanState>(builder: (BuildContext context, BluetoothScanState state) {
      if (state is ScanCompleted) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ScanResultItem(
              state.discoveredDevices[index],
              onTap: () {
                _bluetoothBloc.dispatch(StopScan());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                              value: _bluetoothSelectedDeviceBloc,
                              child: LockAPI(),
                            )));
                _bluetoothSelectedDeviceBloc.bluetoothDevice = state.discoveredDevices[index].device;
              },
            );
          },
          itemCount: state.discoveredDevices.length,
        );
      } else if (state is ScanningDevice) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ScanResultItem(state.discoveredDevices[index]);
          },
          itemCount: state.discoveredDevices.length,
        );
      } else {
        return Container(
          child: Text("Tidak ada perangkat"),
        );
      }
    });
  }
}

class ScanResultItem extends StatelessWidget {
  final flutterBlue.ScanResult _device;
  final Function onTap;

  ScanResultItem(this._device, {Function onTap}) : this.onTap = onTap ?? null;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_device.device.name),
      subtitle: Text(_device.device.id.id),
      onTap: onTap,
    );
  }
}
