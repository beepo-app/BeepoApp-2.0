import 'package:Beepo/utils/hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:web3dart/web3dart.dart';

/// A widget that displays the address name in a [Chip].
///
/// When the widget is "me" (the session user) then this
/// [Chip] displays in vibrant color.
class AddressChip extends HookWidget {
  final EthereumAddress? address;

  AddressChip({Key? key, this.address}) : super(key: Key(address?.hexEip55 ?? ""));

  @override
  Widget build(BuildContext context) {
    var me = useMe();
    var hex = address?.hexEip55 ?? "";
    var name = hex.isEmpty ? "" : "${hex.substring(0, 6)}…${hex.substring(38)}";
    return Chip(
      labelStyle: TextStyle(color: address == me ? Colors.deepPurple : null),
      backgroundColor: address == me ? Colors.deepPurple[50] : null,
      label: Text(name),
    );
  }
}
