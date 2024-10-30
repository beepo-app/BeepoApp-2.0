import 'dart:convert';
import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';

import 'package:Beepo/services/encryption.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/styles.dart';
import 'package:Beepo/widgets/commons.dart';
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
  // ignore: use_super_parameters
  const VerifyCode(
      {key,
      required this.image,
      this.mnemonic,
      this.data,
      this.type,
      required this.name,
      required this.pin})
      : super(key: key);

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  TextEditingController otp = TextEditingController();

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
      body: Container(
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
                controller: otp,
                onChanged: (val) {},
              ),
            ),
            const Spacer(),
            BeepoFilledButtons(
              text: 'Continue',
              onPressed: () async {
                try {
                  debugPrint("=== Starting Account Creation Process ===");
                  debugPrint("Step 1: Validating PIN");

                  if (widget.pin != otp.text) {
                    debugPrint(
                        "PIN Validation Failed: Entered PIN doesn't match");
                    showToast("Invalid PIN. Please try again.");
                    return;
                  }
                  debugPrint("✅ PIN Validated Successfully");

                  // Show loader
                  fullScreenLoader("Creating Your Account!");

                  // Provider Initialization with error catching
                  debugPrint("Step 2: Initializing Providers");
                  late final WalletProvider walletProvider;
                  late final AccountProvider accountProvider;

                  try {
                    walletProvider =
                        Provider.of<WalletProvider>(context, listen: false);
                    accountProvider =
                        Provider.of<AccountProvider>(context, listen: false);
                    debugPrint("✅ Providers Retrieved Successfully");
                  } catch (e) {
                    debugPrint("Provider Error: $e");
                    showToast("Failed to initialize providers");
                    Navigator.pop(context);
                    return;
                  }

                  // Database check
                  if (accountProvider.db == null) {
                    debugPrint("Database Connection Failed: db is null");
                    showToast("Database connection failed");
                    Navigator.pop(context);
                    return;
                  }
                  debugPrint("✅ Database Connection Verified");

                  // Mnemonic Generation with verification
                  debugPrint("Step 3: Generating Mnemonic");
                  late final String mnemonic;
                  try {
                    mnemonic = widget.mnemonic ??
                        await Future(() => walletProvider.generateMnemonic());
                    if (mnemonic.isEmpty)
                      throw Exception("Empty mnemonic generated");
                    debugPrint("✅ Mnemonic Generated Successfully");
                  } catch (e) {
                    debugPrint("Mnemonic Error: $e");
                    showToast("Failed to generate wallet credentials");
                    Get.back();
                    return;
                  }

                  // Encryption
                  debugPrint("Step 4: Encrypting Data");
                  late final Encrypted encrypteData;
                  try {
                    String padding = "000000000000";
                    encrypteData =
                        encryptWithAES('${otp.text}$padding', mnemonic);
                    debugPrint("✅ Data Encrypted Successfully");
                  } catch (e) {
                    debugPrint("Encryption Error: $e");
                    showToast("Encryption failed");
                    Get.back();
                    return;
                  }

                  // MPC Response Check
                  debugPrint("Step 5: Checking MPC Response");
                  final mpcRes = walletProvider.mpcResponse;
                  debugPrint(
                      "MPC Status: ${mpcRes != null ? 'Found' : 'Not Found'}");

                  // Handle wallet initialization based on MPC status
                  late final EthereumAddress? ethAddress;
                  late final String? btcAddress;

                  try {
                    if (mpcRes != null) {
                      debugPrint("Step 6A: Initializing MPC Wallet");
                      await walletProvider.initMPCWalletState(mpcRes.toJson());
                    } else {
                      debugPrint("Step 6B: Initializing Regular Wallet");
                      await walletProvider.initWalletState(mnemonic);
                    }

                    // Get addresses after wallet initialization
                    ethAddress = walletProvider.ethAddress;
                    btcAddress = walletProvider.btcAddress;

                    debugPrint("BTC ADDRESS:$btcAddress");
                    debugPrint("ETH ADDRESS:$ethAddress");

                    if (ethAddress == null)
                      throw Exception("Failed to generate ETH address");
                    debugPrint("✅ Wallet Initialized Successfully");
                    debugPrint("ETH Address: ${ethAddress.toString()}");
                    debugPrint("BTC Address: $btcAddress");
                  } catch (e) {
                    debugPrint("Wallet Initialization Error: $e");
                    showToast("Failed to initialize wallet");
                    Get.back();
                    return;
                  }

                  // Image Processing
                  debugPrint("Step 7: Processing Image");
                  late final Uint8List rawImageData = widget.image;
                  try {
                    final String base64Image = base64Encode(rawImageData);
                    debugPrint("✅ Image Encoded Successfully");
                    debugPrint("PROFILE IMAGE:$base64Image");
                  } catch (e) {
                    debugPrint("Image Processing Error: $e");
                    showToast("Failed to process image");
                    Get.back();
                    return;
                  }

                  debugPrint("User Creation or Data Storage");
                  if (accountProvider.db != null) {
                    try {
                      if (widget.data != null) {
                        final box = Hive.box('Beepo2.0');
                        await Future.wait([
                          box.put('encryptedSeedPhrase', encrypteData.base64),
                          box.put('base64Image', rawImageData),
                          box.put('ethAddress', ethAddress.toString()),
                          box.put('btcAddress', btcAddress),
                          box.put('displayName',
                              widget.data!['response']['displayName']),
                          box.put(
                              'username', widget.data!['response']['username']),
                          box.put('isSignedUp', true),
                        ]);
                      } else {
                        debugPrint("Creating new user");
                        debugPrint("Creating new base64Image:$rawImageData");
                        debugPrint("Creating new name:${widget.name}");
                        debugPrint("Creating new btcAddress:$btcAddress");
                        debugPrint(
                            "Creating new encrypteData:${encrypteData.base16}");
                        debugPrint(
                            "Creating new ethAddress:${ethAddress.toString()}");

                        await accountProvider.createUser(
                          rawImageData,
                          widget.name,
                          ethAddress.toString(),
                          btcAddress,
                          encrypteData,
                        );
                        debugPrint("✅ User Created Successfully");
                      }
                    } catch (e) {
                      debugPrint("Create user account: $e");
                      showToast("Failed to create user account");
                    }
                  }

                  // Session Authorization
                  debugPrint("Step 9: Session Authorization");
                  try {
                    if (!session.initialized) {
                      final credentials =
                          EthPrivateKey.fromHex(walletProvider.ethPrivateKey!);
                      await session.authorize(credentials.asSigner());
                      debugPrint("✅ Session Authorized Successfully");
                    }
                  } catch (e) {
                    debugPrint("Session Authorization Error: $e");
                    showToast("Failed to authorize session");
                    Get.back();
                    return;
                  }

                  // Account State Initialization
                  debugPrint("Step 10: Initializing Account State");
                  try {
                    await accountProvider.initAccountState();
                    await Hive.box('Beepo2.0').put('isAutoLockSwitch', true);
                    debugPrint("✅ Account State Initialized Successfully");
                  } catch (e) {
                    debugPrint("Account State Error: $e");
                    showToast("Failed to initialize account state");
                    Get.back();
                    return;
                  }
                  debugPrint("NAVIGATE TO MAIN SCREEN");
                  Get.back();
                  Get.to(() => const BottomNavHome());
                } catch (e) {
                  debugPrint("Critical Error: $e");
                  showToast("An unexpected error occurred");
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
