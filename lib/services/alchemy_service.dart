import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlchemyService {
  final String _alchemyApiKey = dotenv.env['ALCHEMY_API_KEY'] ?? '';
  final String _alchemyBaseUrl = 'https://eth-mainnet.g.alchemy.com/';

  // Create HTTP client for Alchemy API calls
  final _client = http.Client();

  // Get ERC20 token balance using Alchemy API
  Future<double> getTokenBalance(
      String contractAddress, String walletAddress, String network) async {
    final String url = '$_alchemyBaseUrl$_alchemyApiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jsonrpc': '2.0',
        'method': 'alchemy_getTokenBalances',
        'params': [
          walletAddress,
          [contractAddress]
        ],
        'id': 1
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null &&
          data['result']['tokenBalances'].length > 0) {
        String balance = data['result']['tokenBalances'][0]['tokenBalance'];
        return BigInt.parse(balance) / BigInt.from(10).pow(18);
      }
    }
    return 0.0;
  }

  // Get native token balance using Alchemy API
  Future<double> getNativeBalance(String walletAddress, String network) async {
    final String url = '$_alchemyBaseUrl$_alchemyApiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'jsonrpc': '2.0',
        'method': 'eth_getBalance',
        'params': [walletAddress, 'latest'],
        'id': 1
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null) {
        final balance = BigInt.parse(data['result'].substring(2), radix: 16);
        return balance / BigInt.from(10).pow(18);
      }
    }
    return 0.0;
  }
}
