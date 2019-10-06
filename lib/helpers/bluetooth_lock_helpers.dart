import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

var random = Random.secure();

class BluetoothCommandHelper {
  static Uint8List tokenAcquisition(Uint8List key) {
    List<int> fixedProtocol = [6, 1, 1, 1];

    Uint8List comProtocol = Uint8List.fromList(List.generate(16, (int) => random.nextInt(256), growable: true));

    for (int i = 0; i < 4; i++) {
      comProtocol[i] = fixedProtocol[i];
    }

    final Uint8List encrypted = CommunicationCipher.encrypt(comProtocol, key);

    return encrypted;
  }

  static Uint8List unlocking(Uint8List key, Uint8List token) {
    final List<int> fixedProtocol = [05, 01, 06];
    final List<int> fixedProtocolPassword = [48, 48, 48, 48, 48, 48];
    final List<int> fixedProtocolToken = token;

    Uint8List comProtocol = Uint8List.fromList(List.generate(16, (int) => random.nextInt(256), growable: true));

    for (int i = 0; i < 3; i++) {
      comProtocol[i] = fixedProtocol[i];
    }

    int j = 0;
    for (int i = 3; i < 9; i++) {
      comProtocol[i] = fixedProtocolPassword[j];
      j++;
    }

    j = 0;
    for (int i = 9; i < 13; i++) {
      comProtocol[i] = fixedProtocolToken[j];
      j++;
    }

    final Uint8List encrypted = CommunicationCipher.encrypt(comProtocol, key);
    return encrypted;
  }

  static Uint8List checkPower(Uint8List key, Uint8List token) {
    final List<int> fixedProtocol = [02, 01, 01, 01];
    final List<int> fixedProtocolToken = token;

    Uint8List comProtocol = Uint8List.fromList(List.generate(16, (int) => random.nextInt(256), growable: true));

    for (int i = 0; i < 4; i++) {
      comProtocol[i] = fixedProtocol[i];
    }

    int j = 0;
    for (int i = 4; i < 8; i++) {
      comProtocol[i] = fixedProtocolToken[j];
      j++;
    }

    final Uint8List encrypted = CommunicationCipher.encrypt(comProtocol, key);
    return encrypted;
  }
}

class CommunicationCipher {
  static Uint8List encrypt(Uint8List bytesEncrypt, Uint8List bytesKey) {
    final Key _key = Key(bytesKey);
    final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.ecb, padding: null));
    final IV _iv = IV.fromLength(8);

    final Encrypted _encrypted = _encrypter.encryptBytes(bytesEncrypt, iv: _iv);

    return _encrypted.bytes;
  }

  static Uint8List decrypt(Uint8List bytesEncrypted, Uint8List bytesKey) {
    final Key _key = Key(bytesKey);
    final IV _iv = IV.fromLength(8);
    final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.ecb, padding: null));
    Encrypted _encrypted = Encrypted(bytesEncrypted);

    final _decrypt = _encrypter.decryptBytes(_encrypted, iv: _iv);

    return Uint8List.fromList(_decrypt.toList());
  }
}
