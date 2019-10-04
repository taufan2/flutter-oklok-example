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
      home: LockAPI(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothBloc _bluetoothBloc;

  @override
  void initState() {
    _bluetoothBloc = BluetoothBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Bluetooth"),
      ),
      body: BlocProvider<BluetoothBloc>(
          builder: (BuildContext context) => _bluetoothBloc,
          child: Column(
            children: <Widget>[Upper(), ScanResultList()],
          )),
    );
  }
}

class Upper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BluetoothBloc _bluetoothBloc = BlocProvider.of<BluetoothBloc>(context);
    return Container(
      child: BlocBuilder(
        bloc: _bluetoothBloc,
        builder: (BuildContext context, BluetoothState state) {
          if (state is ScanningDevice) {
            return RaisedButton(
              child: Text("Berhenti"),
              onPressed: () => _bluetoothBloc.dispatch(StopScan()),
            );
          } else {
            return RaisedButton(
              child: Text("Cari Perangkat"),
              onPressed: () => _bluetoothBloc.dispatch(StartScan()),
            );
          }
        },
      ),
    );
  }
}

class ScanResultList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: BlocBuilder<BluetoothBloc, BluetoothState>(
            builder: (BuildContext context, BluetoothState state) {
          if (state is ScanCompleted) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return ScanResultItem(state.devices[index]);
              },
              itemCount: state.devices.length,
            );
          } else {
            return Container(
              child: Text("Tidak ada perangkat"),
            );
          }
        }),
      ),
    );
  }
}

class ScanResultItem extends StatelessWidget {
  final flutterBlue.ScanResult _device;

  ScanResultItem(this._device);

  void _onTap () {
    print(this._device);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_device.device.name),
      subtitle: Text(_device.device.id.id),
      onTap: _onTap ,
    );
  }
}
