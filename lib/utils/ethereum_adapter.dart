import 'package:hive/hive.dart';
import 'package:web3dart/web3dart.dart';

class EthereumAddressAdapter extends TypeAdapter<EthereumAddress> {
  @override
  final int typeId = 0; // Unique ID for the adapter

  @override
  EthereumAddress read(BinaryReader reader) {
    final address = reader.readString();
    return EthereumAddress.fromHex(address);
  }

  @override
  void write(BinaryWriter writer, EthereumAddress obj) {
    writer.writeString(obj.hex);
  }
}
