import 'dart:convert';

import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/auth_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/commons.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'package:xmtp/xmtp.dart';

import '../../Utils/styles.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  TextEditingController otp = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  // bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;
  // String _authorized = 'Not Authorized';
  // bool _isAuthenticating = false;

  // Future<void> authenticateWithBiometrics() async {
  //   bool authenticated = false;
  //   try {
  //     setState(() {
  //       _isAuthenticating = true;
  //       _authorized = 'Authenticating';
  //     });
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'Scan your fingerbeepoPrint (or face or whatever) to authenticate',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //         // biometricOnly: true,
  //       ),
  //     );
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Authenticating';
  //     });
  //   } on PlatformException catch (e) {
  //     beepoPrint(e);
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Error - ${e.message}';
  //     });
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   final String message = authenticated ? 'Authorized' : 'Not Authorized';
  //   setState(() {
  //     _authorized = message;
  //   });
  // }

  logUserIn(response) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    fullScreenLoader("Logging In!");

    beepoPrint('object 0000');

    if (response.contains('privKey')) {
      Map data = jsonDecode(response);
      await walletProvider.initMPCWalletState(data);
      await accountProvider.initAccountState();
      var ds = await chatProvider.getAllStatus(accountProvider.db);
      beepoPrint(ds);
      EthPrivateKey credentials =
          EthPrivateKey.fromHex(walletProvider.ethPrivateKey!);
      if (session.initialized == false) {
        await session.authorize(credentials.asSigner());
      }

      Future.delayed(const Duration(seconds: 3));
      Hive.box('Beepo2.0').put('isLocked', false);
      Get.to(() => const BottomNavHome());

      return;
    }
    beepoPrint('object 111');
    await walletProvider.initWalletState(response);
    EthPrivateKey credentials =
        EthPrivateKey.fromHex(walletProvider.ethPrivateKey!);

    if (session.initialized == false) {
      await session.authorize(credentials.asSigner());
    }
    await accountProvider.initAccountState();
    var ds = await chatProvider.getAllStatus(accountProvider.db);
    beepoPrint(ds);
    Hive.box('Beepo2.0').put('isLocked', false);
    Get.to(() => const BottomNavHome());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/logo2.png',
                height: 160,
                width: 160,
              ),
              const SizedBox(height: 30),
              const Text(
                'Enter your PIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
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
                    fieldHeight: 40,
                    fieldWidth: 40,
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
                  onCompleted: (v) {},
                  onChanged: (String value) async {
                    if (value.length == 4) {
                      String response = await login(value);
                      if (response.contains("Incorrect Pin Entered")) {
                        showToast("Incorrect Pin Entered");
                        return;
                      }

                      logUserIn(response);
                    }
                  },
                ),
              ),
              const SizedBox(height: 40, width: double.infinity),
              // const Text(
              //   'Or use biometrics',
              //   style: TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // const SizedBox(height: 20),
              // GestureDetector(
              //   onTap: () async {
              //     var canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
              //     var canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
              //     beepoPrint(canAuthenticate);
              //     beepoPrint(canAuthenticateWithBiometrics);
              //     if (canAuthenticateWithBiometrics) {
              //       await authenticateWithBiometrics();
              //     }
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       color: Colors.grey.withOpacity(.3),
              //     ),
              //     padding: const EdgeInsets.all(10),
              //     child: const Icon(
              //       Icons.fingerprint,
              //       size: 40,
              //       color: secondaryColor,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
