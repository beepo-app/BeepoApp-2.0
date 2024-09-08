import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/wallet/send_token_pin_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SendTokenConfirmScreen extends StatefulWidget {
  final Map? asset;
  final Map? data;
  final String? type;
  const SendTokenConfirmScreen({
    this.asset,
    this.data,
    super.key,
    this.type,
  });

  @override
  State<SendTokenConfirmScreen> createState() => _SendTokenConfirmScreenState();
}

class _SendTokenConfirmScreenState extends State<SendTokenConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    Map data = widget.data!;
    Map asset = widget.asset!;

    //beepoPrint(asset);

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
              text: "${data['amount']} ${asset["ticker"]}",
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
                text: data['address'],
                fontSize: 12.sp,
                color: const Color(0xff0e014c),
              ),
            ),
            SizedBox(height: 50.h),
            AppText(
              text: "Gas Fee: ${data['gasFee']} ${asset["nativeTicker"]}",
              fontSize: 14.sp,
              color: const Color(0xff0e014c),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            BeepoFilledButtons(
              text: "Approve",
              color: const Color(0xff0e014c),
              onPressed: () {
                String amtInUSD = (Decimal.tryParse(data['amount']) == null
                        ? int.tryParse(data['amount']) == null
                            ? 0
                            : int.tryParse(data['amount'])! *
                                int.parse(asset['current_price'])
                        : Decimal.tryParse(data['amount'])! *
                            Decimal.parse(asset['current_price'].toString()))
                    .toString();

                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SendTokenPinScreen(txData: {
                    'asset': asset,
                    'data': data,
                    "amtInUSD": amtInUSD
                  }, type: widget.type);
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
