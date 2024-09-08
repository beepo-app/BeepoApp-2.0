import 'dart:convert';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/auth_provider.dart';
import 'package:Beepo/providers/chat_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/wallet/transfer_success.dart';
import 'package:Beepo/session/foreground_session.dart';
import 'package:Beepo/utils/styles.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/commons.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:xmtp/xmtp.dart' as xmtp;

class SendTokenPinScreen extends StatefulWidget {
  final Map? txData;
  final String? type;

  const SendTokenPinScreen({
    super.key,
    this.txData,
    this.type,
  });

  @override
  State<SendTokenPinScreen> createState() => _SendTokenPinScreenState();
}

class _SendTokenPinScreenState extends State<SendTokenPinScreen> {
  TextEditingController otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Map? txData = widget.txData;
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xff0e014c),
        toolbarHeight: 75.h,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
        title: Column(
          children: [
            SizedBox(height: 15.h),
            AppText(
              text: "Send Token",
              fontWeight: FontWeight.w900,
              fontSize: 25.sp,
              color: AppColors.white,
            ),
            AppText(
              text: "Confirm Transaction",
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: AppColors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            AppText(
              text: "You are sending",
              fontSize: 14.sp,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 10.h),
            AppText(
              text: "${txData!['data']['amount']} ${txData['asset']['ticker']}",
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff0e014c),
            ),
            SizedBox(height: 10.h),
            AppText(
              text: "to the following wallet",
              fontSize: 14.sp,
              color: AppColors.textGrey,
            ),
            SizedBox(height: 10.h),
            Center(
              child: AppText(
                text: "${txData['data']['address']}",
                fontSize: 12.sp,
                color: const Color(0xff0e014c),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
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
                onChanged: (val) async {
                  if (otp.text.length == 4) {
                    String response = await login(otp.text);

                    if (response.contains("Incorrect Pin Entered")) {
                      showToast("Incorrect Pin Entered");
                      return;
                    }
                    loadingDialog('Sending ${txData['data']['amount']} ${txData['asset']['ticker']}');

                    Map asset = txData['asset'];
                    Map data = txData['data'];

                    if (asset['native'] != null && asset['native'] == true) {
                      await walletProvider.sendNativeToken(data['address'], asset['rpc'], data['amount']);
                    } else {
                      await walletProvider.sendERC20(asset['contractAddress'], data['address'], asset['rpc'], data['amount']);
                    }

                    if (widget.type != null) {
                      List<xmtp.Conversation> conversations = chatProvider.convos!;
                      List<xmtp.Conversation> convo =
                          conversations.where((element) => element.peer.toString() == data['address'].toString()).toList();

                      await session.sendMessage(
                          convo[0].topic,
                          jsonEncode(
                            {
                              'amount': txData['data']['amount'],
                              'ticker': txData['asset']['ticker'],
                              "amtInUSD": txData['amtInUSD'],
                              "inChatTxChat-BeepoV2": true,
                              "sender": walletProvider.ethAddress.toString(),
                            },
                          ));
                    }

                    Get.to(() => TransferSuccess(txData: txData));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
