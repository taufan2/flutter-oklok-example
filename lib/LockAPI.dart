import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:oklok/helpers/bluetooth_lock.dart';

class LockAPI extends StatelessWidget {

  void _tokenAcquisition() {

//    Uint8List _key = Uint8List.fromList([0x12, 0x08, 0x13, 0x89, 0x63, 0x90, 0x35, 0x80, 0x45, 0x86, 0x26, 0x48, 0x40, 0x15, 0x51, 0x51]);     0   1     2     3     4     5     6     7     8     9     10    11    12    13    14      15
    Uint8List _key = Uint8List.fromList([0x3a, 0x60, 0x43, 0x2a, 0x5c, 0x01, 0x21, 0x1f, 0x29, 0x1e, 0x0f, 0x4e, 0x0c, 0x13, 0x28, 0x25]);

    BluetoothLock command = BluetoothLock(_key);
    Uint8List encrypted = command.tokenAcquisition();
    print('Encrypted : $encrypted');

    Uint8List decrypted = BluetoothCipher.decrypt(encrypted, _key);
    print('Decrypted : $decrypted');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lock API"),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Token Acquisition"),
            onPressed: _tokenAcquisition,
          )
        ],
      ),
    );
  }
}
