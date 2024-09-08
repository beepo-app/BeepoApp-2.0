import 'package:encrypt/encrypt.dart';
import 'package:hive/hive.dart';

part 'encrypted_seed.g.dart';

@HiveType(typeId: 43)
class EncryptSeed extends HiveObject {
  @HiveField(0)
  Encrypted encryptedSeed;

  EncryptSeed({required this.encryptedSeed});
}
