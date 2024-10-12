import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/bottom_nav.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class TransferSuccess extends StatefulWidget {
  final Map? txData;
  const TransferSuccess({
    this.txData,
    super.key,
  });

  @override
  State<TransferSuccess> createState() => _TransferSuccessState();
}

class _TransferSuccessState extends State<TransferSuccess> {
  @override
  Widget build(BuildContext context) {
    Map asset = widget.txData!['asset'];
    Map data = widget.txData!['data'];
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.getAssets();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.secondaryColor,
          centerTitle: true,
          toolbarHeight: 40.h,
          title: Text(
            "Transaction",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20.sp,
              color: AppColors.white,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Lottie.asset(
                'assets/lottie/lottie_success.json',
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              AppText(
                text: "${data['amount']} ${asset['ticker']}",
                fontSize: 15.sp,
                color: const Color(0xff0d004c),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              const AppText(text: 'is on it\'s way to:'),
              SizedBox(height: 20.h),
              AppText(
                text: data['address'],
                fontSize: 12.sp,
                color: const Color(0xff0d004c),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              BeepoFilledButtons(
                text: 'Done',
                color: AppColors.secondaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const BottomNavHome();
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
