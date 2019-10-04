import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

var random = Random.secure();

class BluetoothLock {
  Uint8List _key;

  BluetoothLock(Uint8List key) {
    this._key = key;
  }

  Uint8List tokenAcquisition() {
    List<int> fixedProtocol = [0x06, 0x01, 0x01, 0x01];
    int fixedStartFromIndex = 0;

    Uint8List comProtocol = Uint8List.fromList(
        List.generate(16, (int) => random.nextInt(256), growable: true));

    for (int i = fixedStartFromIndex; i < fixedProtocol.length; i++) {
      comProtocol[i] = fixedProtocol[i];
    }

    print('Before Encrypt : $comProtocol');

    final Uint8List encrypted = BluetoothCipher.encrypt(comProtocol, this._key);

    return encrypted;
  }
}

class BluetoothCipher {
  static Uint8List encrypt(Uint8List bytesEncrypt, Uint8List bytesKey) {
    final Key _key = Key(bytesKey);
    final Encrypter _encrypter =
        Encrypter(AES(_key, mode: AESMode.ecb, padding: null));
    final IV _iv = IV.fromLength(8);

    final Encrypted _encrypted = _encrypter.encryptBytes(bytesEncrypt, iv: _iv);

    return _encrypted.bytes;
  }

  static Uint8List decrypt(Uint8List bytesEncrypted, Uint8List bytesKey) {
    final Key _key = Key(bytesKey);
    final IV _iv = IV.fromLength(8);
    final Encrypter _encrypter =
        Encrypter(AES(_key, mode: AESMode.ecb, padding: null));
    Encrypted _encrypted = Encrypted(bytesEncrypted);

    final _decrypt = _encrypter.decryptBytes(_encrypted, iv: _iv);

    return Uint8List.fromList(_decrypt.toList());
  }
}
