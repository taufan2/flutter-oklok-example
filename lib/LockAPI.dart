import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oklok/bloc/bloc.dart';

class LockAPI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc = BlocProvider.of<BluetoothSelectedDeviceBloc>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _bluetoothSelectedDeviceBloc,
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bluetooth Lock API"),
          actions: <Widget>[ConnectDeviceButton()],
        ),
        body: Column(
          children: <Widget>[BluetoothStateView()],
        ),
        bottomNavigationBar: Buttons(),
      ),
    );
  }
}

class ConnectDeviceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc = BlocProvider.of<BluetoothSelectedDeviceBloc>(context);
    return BlocBuilder<BluetoothSelectedDeviceBloc, BluetoothSelectedDeviceState>(builder: (context, state) {

      if (state is InitialSelectedBluetoothDeviceState) {
        return FlatButton(
          textColor: Colors.white,
          child: Text('Connect'),
          onPressed: () {
            _bluetoothSelectedDeviceBloc.dispatch(ConnectToDevice());
          },
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        );
      } else if (state is ConnectedToDevice) {
        return FlatButton(
          textColor: Colors.white,
          child: Text('Disconnect'),
          onPressed: () {
            _bluetoothSelectedDeviceBloc.dispatch(DisconnectFromDevice());
          },
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        );
      } else {
        return Container();
      }



    });
  }
}

class BluetoothStateView extends StatefulWidget {
  @override
  _BluetoothStateViewState createState() => _BluetoothStateViewState();
}

class _BluetoothStateViewState extends State<BluetoothStateView> {
  BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc;

  @override
  void initState() {
    super.initState();
    _bluetoothSelectedDeviceBloc = BlocProvider.of<BluetoothSelectedDeviceBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothSelectedDeviceBloc, BluetoothSelectedDeviceState>(builder: (context, state) {
      return Expanded(
        child: Card(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Status"),
                subtitle: Builder(
                  builder: (context) {
                    if (state is ConnectingToDevice) {
                      return Text('Connecting');
                    } else if (state is ConnectedToDevice) {
                      return Text('Connected');
                    } else {
                      return Text('Disconnect');
                    }
                  },
                ),
                dense: true,
              ),
              ListTile(
                title: Text("Device Name"),
                subtitle: Text(_bluetoothSelectedDeviceBloc.device.name),
                dense: true,
              ),
              ListTile(
                title: Text("Mac Address"),
                subtitle: Text(_bluetoothSelectedDeviceBloc.device.id.id),
                dense: true,
                onTap: () {
                  if (state is ConnectedToDevice) {}
                },
              ),
              ListTile(
                title: Text("Command Type"),
                subtitle: Builder(
                  builder: (context) {
                    if (state is ConnectedToDevice) {
                      return Text(state.bluetoothEventCommunication.type.toString());
                    } else {
                      return Text(
                        'null',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      );
                    }
                  },
                ),
                dense: true,
              ),
              ListTile(
                title: Text("Response Decrypted"),
                subtitle: Builder(
                  builder: (context) {
                    if (state is ConnectedToDevice) {
                      return Text(state.bluetoothEventCommunication.response.toString());
                    } else {
                      return Text(
                        'null',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      );
                    }
                  },
                ),
                dense: true,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class Buttons extends StatefulWidget {
  @override
  _ButtonsState createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  BluetoothSelectedDeviceBloc _bluetoothSelectedDeviceBloc;

  Uint8List token;

  @override
  void initState() {
    super.initState();
    _bluetoothSelectedDeviceBloc = BlocProvider.of<BluetoothSelectedDeviceBloc>(context);
  }

  void _tokenAcquisition() {
    this._bluetoothSelectedDeviceBloc.dispatch(TokenAcquisition());
  }

  void _unlocking() {
    this._bluetoothSelectedDeviceBloc.dispatch(BluetoothDeviceUnlock());
  }

  void _checkPower() {
    this._bluetoothSelectedDeviceBloc.dispatch(BluetoothDeviceCheckPower());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothSelectedDeviceBloc, BluetoothSelectedDeviceState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(Icons.vpn_key),
                label: Text("Token"),
                onPressed: (state is ConnectedToDevice) ? _tokenAcquisition : null,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.lock_open),
                label: Text("Unlock"),
                onPressed: (state is ConnectedToDevice) ? _unlocking: null,
              ),
              RaisedButton.icon(
                icon: Icon(Icons.battery_std),
                label: Text("Battery"),
                onPressed: (state is ConnectedToDevice) ? _checkPower: null,
              )
            ],
          ),
        );
      }
    );
  }
}
