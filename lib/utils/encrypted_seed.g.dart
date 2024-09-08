// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_seed.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EncryptSeedAdapter extends TypeAdapter<EncryptSeed> {
  @override
  final int typeId = 43;

  @override
  EncryptSeed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EncryptSeed(
      encryptedSeed: fields[0] as Encrypted,
    );
  }

  @override
  void write(BinaryWriter writer, EncryptSeed obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.encryptedSeed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptSeedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
