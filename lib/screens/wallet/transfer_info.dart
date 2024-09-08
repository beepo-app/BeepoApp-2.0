import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TransferInfo extends StatelessWidget {
  final String? walletTicker;
  final Map? data;
  const TransferInfo({Key? key, this.walletTicker, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    beepoPrint(data);
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 7, right: 25),
                    height: 90.h,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xff0e014c),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.h,
                        ),
                        Row(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_outlined,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Get.back();
                                }),
                            AppText(
                              text: "Transaction Details",
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppText(
              text: "${data!['tx']['value']} ${data!['data']['ticker']}",
              fontWeight: FontWeight.w900,
              color: data!['tx']['type'] == 'Send'
                  ? Colors.red
                  : Colors.green.shade500,
              fontSize: 20.sp,
            ),
            SizedBox(height: 5.h),
            AppText(
              text:
                  "~ \$${(data!['tx']['value'] * data!['data']['current_price']).toStringAsFixed(2)}",
              fontWeight: FontWeight.w900,
              color: AppColors.textGrey,
              fontSize: 14.sp,
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: "Date",
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    fontSize: 14.sp,
                  ),
                  AppText(
                    text: DateFormat('M-d-yyyy hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            data!['tx']['timestamp'] * 1000)),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    fontSize: 14.sp,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: "Status",
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    fontSize: 14.sp,
                  ),
                  AppText(
                    text: "Completed",
                    fontWeight: FontWeight.w900,
                    color: Colors.green.shade500,
                    fontSize: 14.sp,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: "Transaction Type",
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    fontSize: 14.sp,
                  ),
                  AppText(
                    text: "Unknown",
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    fontSize: 14.sp,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: AppText(
                      text: "Recipient",
                      fontWeight: FontWeight.w900,
                      color: AppColors.textGrey,
                      fontSize: 14.sp,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: data!['tx']['to'].toString()));
                        showToast('Address Copied To Clipboard!');
                      },
                      child: Text(
                        data!['tx']['to'].toString(),
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: "Network Fee",
                    fontWeight: FontWeight.w900,
                    color: AppColors.textGrey,
                    textAlign: TextAlign.right,
                    fontSize: 14.sp,
                  ),
                  const Spacer(),
                  Expanded(
                    child: AppText(
                      text:
                          "${data!['tx']['gasfee'].toStringAsFixed(7)} ${data!['data']['nativeTicker'].toString()} \$${(data!['tx']['gasfee'] * data!['data']['current_price']).toStringAsFixed(7)}",
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      textAlign: TextAlign.right,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              child: AppText(
                text: "More Details",
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
              ),
              onPressed: () async {
                final Uri url = Uri.parse(data!['tx']['url']);
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
