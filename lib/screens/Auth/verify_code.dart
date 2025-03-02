import 'dart:convert';
import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/services/encryption.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/styles.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:xmtp/xmtp.dart';

class VerifyCode extends StatefulWidget {
  final Map? data;
  final Uint8List image;
  final String name;
  final String? type;
  final String pin;
  final String? mnemonic;

  const VerifyCode({
    super.key,
    required this.image,
    this.mnemonic,
    this.data,
    this.type,
    required this.name,
    required this.pin,
  });

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verify your PIN",
          style: TextStyle(
            color: Color(0xb20e014c),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/pin_img.png',
                  height: 127,
                  width: 127,
                ),
                const SizedBox(height: 70),
                SizedBox(
                  width: size.width * 0.6,
                  child: PinCodeTextField(
                    appContext: context,
                    keyboardType: TextInputType.number,
                    length: 4,
                    obscureText: true,
                    obscuringCharacter: '*',
                    blinkWhenObscuring: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      fieldHeight: 30,
                      fieldWidth: 30,
                      activeColor: primaryColor,
                      inactiveFillColor: Colors.white,
                      inactiveColor: Colors.grey,
                      borderWidth: 3,
                      fieldOuterPadding: EdgeInsets.zero,
                      activeFillColor: Colors.white,
                      selectedColor: primaryColor,
                      selectedFillColor: Colors.white,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: _otpController,
                    onChanged: (val) {},
                  ),
                ),
                const Spacer(),
                BeepoFilledButtons(
                  text: 'Continue',
                  onPressed: () async {
                    await _handleContinue();
                  },
                ),
              ],
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      debugPrint("=== Starting Account Creation Process ===");

      // Step 1: Validate PIN
      debugPrint("Validating PIN...");
      if (!_validatePin()) {
        debugPrint("PIN validation failed.");
        setState(() => _isLoading = false);
        return;
      }
      debugPrint("PIN validation successful.");

      // Step 2: Initialize Providers
      debugPrint("Initializing WalletProvider and AccountProvider...");
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      debugPrint("Providers initialized.");

      // Step 3: Generate Mnemonic
      debugPrint("Generating mnemonic...");
      final mnemonic = await _generateMnemonic(walletProvider);
      debugPrint("Mnemonic generated: $mnemonic");

      // Step 4: Encrypt Data
      debugPrint("Encrypting data...");
      final encryptedData = _encryptData(mnemonic);
      debugPrint("Data encrypted successfully.");

      // Step 5: Initialize Wallet
      debugPrint("Initializing wallet...");
      final (ethAddress, btcAddress) =
          await _initializeWallet(walletProvider, mnemonic);
      debugPrint(
          "Wallet initialized. ETH Address: $ethAddress, BTC Address: $btcAddress");

      // Step 6: Process Image
      debugPrint("Processing image...");
      _processImage(widget.image);
      debugPrint("Image processed successfully.");

      // Step 7: Create or Update User
      debugPrint("Creating or updating user...");
      await _createOrUpdateUser(
          accountProvider, encryptedData, ethAddress, btcAddress);
      debugPrint("User created/updated successfully.");

      // Step 8: Authorize Session
      debugPrint("Authorizing session...");
      await _authorizeSession(walletProvider);
      debugPrint("Session authorized successfully.");

      // Step 9: Initialize Account State
      debugPrint("Initializing account state...");
      await _initializeAccountState(accountProvider);
      debugPrint("Account state initialized successfully.");

      // Step 10: Navigate to Main Screen
      debugPrint("Navigating to BottomNavHome...");
      Get.offAll(() => const BottomNavHome());
      debugPrint("Navigation complete.");
    } catch (e) {
      debugPrint("Critical Error: $e");
      showToast("An unexpected error occurred");
    } finally {
      debugPrint("Stopping loading indicator.");
      setState(() => _isLoading = false);
    }
  }

  bool _validatePin() {
    if (widget.pin != _otpController.text) {
      showToast("Invalid PIN. Please try again.");
      return false;
    }
    return true;
  }

  Future<String> _generateMnemonic(WalletProvider walletProvider) async {
    try {
      final mnemonic = widget.mnemonic ?? walletProvider.generateMnemonic();
      if (mnemonic.isEmpty) throw Exception("Empty mnemonic generated");
      return mnemonic;
    } catch (e) {
      debugPrint("Mnemonic Error: $e");
      showToast("Failed to generate wallet credentials");
      rethrow;
    }
  }

  Encrypted _encryptData(String mnemonic) {
    try {
      String padding = "000000000000";
      return encryptWithAES('${_otpController.text}$padding', mnemonic);
    } catch (e) {
      debugPrint("Encryption Error: $e");
      showToast("Encryption failed");
      rethrow;
    }
  }

  Future<(EthereumAddress?, String?)> _initializeWallet(
      WalletProvider walletProvider, String mnemonic) async {
    try {
      if (walletProvider.mpcResponse != null) {
        await walletProvider
            .initMPCWalletState(walletProvider.mpcResponse!.toJson());
      } else {
        await walletProvider.initWalletState(mnemonic);
      }

      final ethAddress = walletProvider.ethAddress;
      final btcAddress = walletProvider.btcAddress;

      if (ethAddress == null) throw Exception("Failed to generate ETH address");
      return (ethAddress, btcAddress);
    } catch (e) {
      debugPrint("Wallet Initialization Error: $e");
      showToast("Failed to initialize wallet");
      rethrow;
    }
  }

  void _processImage(Uint8List image) {
    try {
      final String base64Image = base64Encode(image);
      debugPrint("PROFILE IMAGE:$base64Image");
    } catch (e) {
      debugPrint("Image Processing Error: $e");
      showToast("Failed to process image");
      rethrow;
    }
  }

  Future<void> _createOrUpdateUser(
    AccountProvider accountProvider,
    Encrypted encryptedData,
    EthereumAddress? ethAddress,
    String? btcAddress,
  ) async {
    try {
      if (accountProvider.db != null) {
        if (widget.data != null) {
          final box = Hive.box('Beepo2.0');
          await Future.wait([
            box.put('encryptedSeedPhrase', encryptedData.base64),
            box.put('base64Image', widget.image),
            box.put('ethAddress', ethAddress.toString()),
            box.put('btcAddress', btcAddress),
            box.put('displayName', widget.data!['response']['displayName']),
            box.put('username', widget.data!['response']['username']),
            box.put('isSignedUp', true),
          ]);
        } else {
          await accountProvider.createUser(
            widget.image,
            widget.name,
            ethAddress.toString(),
            btcAddress,
            encryptedData,
          );
        }
      }
    } catch (e) {
      debugPrint("Create user account: $e");
      showToast("Failed to create user account");
      rethrow;
    }
  }

  Future<void> _authorizeSession(WalletProvider walletProvider) async {
    try {
      if (!session.initialized) {
        final credentials =
            EthPrivateKey.fromHex(walletProvider.ethPrivateKey!);
        await session.authorize(credentials.asSigner());
      }
    } catch (e) {
      debugPrint("Session Authorization Error: $e");
      showToast("Failed to authorize session");
      rethrow;
    }
  }

  Future<void> _initializeAccountState(AccountProvider accountProvider) async {
    try {
      await accountProvider.initAccountState();
      await Hive.box('Beepo2.0').put('isAutoLockSwitch', true);
    } catch (e) {
      debugPrint("Account State Error: $e");
      showToast("Failed to initialize account state");
      rethrow;
    }
  }
}
