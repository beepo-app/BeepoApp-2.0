import 'package:Beepo/utils/logger.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class ERC20 {
  Future<List<dynamic>> query(String functionName, List<dynamic> args,
      ethClient, contractAddress) async {
    final contract = await loadContract(contractAddress);
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<DeployedContract> loadContract(contractAddress) async {
    String abi = await rootBundle.loadString("assets/abi/abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "Gold"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<double> getBalance(
      EthereumAddress credentialAddress, ethClient, contractAddress) async {
    List<dynamic> response = await query(
        "balanceOf", [credentialAddress], ethClient, contractAddress);
    var d = (Decimal.fromBigInt(response[0]) / Decimal.parse(1e+18.toString()))
        .toDouble();
    return d;
  }

  Future<String> sendERC20Token(
      String functionName,
      List<dynamic> args,
      Web3Client ethClient,
      Credentials key,
      contractAddress,
      ethAddress) async {
    DeployedContract contract = await loadContract(contractAddress);
    final ethFunction = contract.function(functionName);

    BigInt chainID = await ethClient.getChainId();
    var gasPrice = await ethClient.getGasPrice();

    try {
      var txHash = await ethClient.sendTransaction(
        key,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: args,
          maxGas: 100000,
          gasPrice: EtherAmount.inWei(gasPrice.getInWei),
          nonce: await ethClient.getTransactionCount(ethAddress,
              atBlock: const BlockNum.pending()),
          from: contract.address,
        ),
        chainId: chainID.toInt(),
      );
      await Future.delayed(const Duration(seconds: 5));
      beepoPrint(txHash);
      var transactionReceipt = await ethClient.getTransactionReceipt(txHash);
      beepoPrint(
          "Transaction receipt status: ${transactionReceipt?.status.toString()}");
    } catch (err) {
      beepoPrint('rror 78 erc20 $err.toString()');
    }

    return 'end of tx';
  }
}
