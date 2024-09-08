import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:encrypt/encrypt.dart';

String decryptWithAES(String key, Encrypted encryptedData) {
  try {
    final cipherKey = Key.fromUtf8(key);
    final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(key.substring(0, 16));
    return encryptService.decrypt(encryptedData, iv: initVector);
  } catch (e) {
    return 'Incorrect Pin Entered';
  }
}

Encrypted encryptWithAES(String key, String plainText) {
  final cipherKey = Key.fromUtf8(key);
  final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(key.substring(0, 16));
  Encrypted encryptedData = encryptService.encrypt(plainText, iv: initVector);
  return encryptedData;
}

encrypt(String inputkey, String plainText) {
  Uint8List key = Uint8List.fromList(inputkey.codeUnits);
  Uint8List iv = Uint8List.fromList(inputkey.codeUnits);

  AesCrypt crypt = AesCrypt();
  crypt.aesSetKeys(key, iv);
  Uint8List srcData = Uint8List.fromList(plainText.codeUnits);

  Uint8List encryptedData = crypt.aesEncrypt(srcData);
  return encryptedData;
}

decrypt(String inputkey, Uint8List encryptedData) {
  Uint8List key = Uint8List.fromList(inputkey.codeUnits);

  Uint8List iv = Uint8List.fromList(inputkey.codeUnits);

  AesCrypt crypt = AesCrypt();
// Sets the encryption key and IV.
// crypt(key, iv);
  crypt.aesSetKeys(key, iv);

// Encrypts the data. Padding scheme - null byte (0x00).
  Uint8List decryptedData = crypt.aesDecrypt(encryptedData);
  return String.fromCharCodes(decryptedData);
}
