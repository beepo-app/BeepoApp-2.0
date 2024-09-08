import 'dart:convert';
import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';

import 'package:Beepo/services/encryption.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/logger.dart';
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          //size: 30.0,
          onPressed: () {},
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
              width: Get.size.width * 0.6,
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
            const Spacer(),
            BeepoFilledButtons(
              text: 'Continue',
              onPressed: () async {
                //beepoPrint(widget.pin);
                if (widget.pin == otp.text) {
                  fullScreenLoader("Creating Your Account!");
                  final walletProvider =
                      Provider.of<WalletProvider>(context, listen: false);
                  final accountProvider =
                      Provider.of<AccountProvider>(context, listen: false);

                  String mnemonic =
                      widget.mnemonic ?? walletProvider.generateMnemonic();

                  String padding = "000000000000";
                  Encrypted encrypteData =
                      encryptWithAES('${otp.text}$padding', mnemonic);
                  var mpcRes = walletProvider.mpcResponse;

                  if (mpcRes != null) {
                    encrypteData = encryptWithAES(
                        '${otp.text}$padding', jsonEncode(mpcRes));

                    // beepoPrint(mpcRes.privKey);
                    await walletProvider.initMPCWalletState((mpcRes).toJson());

                    EthereumAddress? ethAddress = walletProvider.ethAddress;
                    String? btcAddress = walletProvider.btcAddress;
                    String base64Image = base64Encode(widget.image);

                    if (ethAddress != null && accountProvider.db != null) {
                      try {
                        if (widget.data != null) {
                          await Hive.box('Beepo2.0').put(
                              'encryptedSeedPhrase', (encrypteData.base64));
                          await Hive.box('Beepo2.0')
                              .put('base64Image', base64Image);
                          await Hive.box('Beepo2.0')
                              .put('ethAddress', ethAddress.toString());
                          await Hive.box('Beepo2.0')
                              .put('btcAddress', btcAddress);
                          await Hive.box('Beepo2.0').put('displayName',
                              widget.data!['response']['displayName']);
                          await Hive.box('Beepo2.0').put(
                              'username', widget.data!['response']['username']);
                          await Hive.box('Beepo2.0').put('isSignedUp', true);
                        } else {
                          await accountProvider.createUser(
                            base64Image,
                            accountProvider.db,
                            widget.name,
                            ethAddress.toString(),
                            btcAddress,
                            encrypteData,
                          );
                        }

                        EthPrivateKey credentials = EthPrivateKey.fromHex(
                            walletProvider.ethPrivateKey!);
                        if (session.initialized == false) {
                          await session.authorize(credentials.asSigner());
                        }
                        await accountProvider.initAccountState();

                        Hive.box('Beepo2.0').put('isAutoLockSwitch', true);
                        Get.back();

                        Get.to(
                          () => const BottomNavHome(),
                        );
                        return;
                      } catch (e) {
                        if (kDebugMode) {
                          beepoPrint(e.toString());
                        }
                      }
                    }
                    showToast("An Error Occured Please Try Again Later!");
                    return;
                  }

                  await walletProvider.initWalletState(mnemonic);

                  EthereumAddress? ethAddress = walletProvider.ethAddress;
                  String? btcAddress = walletProvider.btcAddress;
                  String base64Image = base64Encode(widget.image);

                  // beepoPrint(mpcRes);
                  // beepoPrint(mnemonic);
                  if (ethAddress != null && accountProvider.db != null) {
                    try {
                      await accountProvider.createUser(
                        base64Image,
                        accountProvider.db,
                        widget.name,
                        ethAddress.toString(),
                        btcAddress,
                        encrypteData,
                      );

                      EthPrivateKey credentials =
                          EthPrivateKey.fromHex(walletProvider.ethPrivateKey!);
                      if (session.initialized == false) {
                        await session.authorize(credentials.asSigner());
                      }
                      await accountProvider.initAccountState();

                      Get.back();
                      Get.to(
                        () => const BottomNavHome(),
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        beepoPrint(e.toString());
                      }
                    }
                  }
                  showToast("An Error Occured Please Try Again Later!");
                  return;
                }
              },
            ),
            const SizedBox(height: 40, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
