import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';

import '../services/encryption.dart';

Future<String> login(String pin) async {
  String padding = "000000000000";
  String encryptedSeedPhrase =
      await Hive.box('Beepo2.0').get('encryptedSeedPhrase');
  String decryptedData = decryptWithAES(
    '$pin$padding',
    Encrypted(
      base64Decode(encryptedSeedPhrase),
    ),
  );
  return decryptedData;
}
