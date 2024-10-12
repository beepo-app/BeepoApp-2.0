import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TokenScreenScan extends StatelessWidget {
  final Map<String, dynamic>? data;
  const TokenScreenScan({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        toolbarHeight: 50.h,
        title: AppText(
          text: "Recieve Token",
          fontSize: 20.sp,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);

            // Navigator.push(context, MaterialPageRoute(builder: (context) {
            //   return const ReceivedAssetScreen(assets_: [
            //     {'assets': 'ooo'}
            //   ]);
            // }));
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            Image.network(
              data!['logoUrl'],
              height: 80.h,
              width: 80.w,
            ),
            AppText(
              text: data!['ticker'],
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            SizedBox(height: 15.h),
            SizedBox(
              height: 200.h,
              width: 250.w,
              child: QrImageView(
                data: data!['address'],
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: data!['address']));
                showToast('Address Copied To Clipboard!');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data!['address'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  const Icon(
                    Icons.copy_outlined,
                    color: AppColors.secondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
