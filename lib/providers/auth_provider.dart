import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';
import '../services/encryption.dart';

Future<String> login(String pin) async {
  try {
    String padding = "000000000000";
    String? encryptedSeedPhrase =
        await Hive.box('Beepo2.0').get('encryptedSeedPhrase');

    // Handle null encryptedSeedPhrase
    if (encryptedSeedPhrase == null) {
      return "Error: No encrypted seed phrase found. Please set up your account again.";
    }

    // Decrypt the seed phrase
    String decryptedData = decryptWithAES(
      '$pin$padding',
      Encrypted(base64Decode(encryptedSeedPhrase)),
    );

    // Validate the decrypted data
    if (decryptedData.isEmpty) {
      return "Error: Failed to decrypt seed phrase. Incorrect PIN or corrupted data.";
    }

    return decryptedData;
  } catch (e) {
    return "Error: An unexpected error occurred. Please try again.";
  }
}
