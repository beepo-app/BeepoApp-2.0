import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
        toolbarHeight: 45.h,
        backgroundColor: AppColors.secondaryColor,
        title: AppText(
          text: "About",
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.white,
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              AppText(
                text: "Beepo 2.0",
                fontWeight: FontWeight.w900,
                color: const Color(0xff0e014c),
                fontSize: 12.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              AppText(
                text: "Testnet version",
                fontWeight: FontWeight.w900,
                color: const Color(0xff0e014c),
                fontSize: 12.sp,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                  onTap: () async {
                    final Uri url =
                        Uri.parse('https://beepo.gitbook.io/terms-of-use/');
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  child: AppText(
                    text: "Read our Terms of use and Privacy Policy here",
                    fontWeight: FontWeight.w900,
                    color: const Color(0xff0e014c),
                    fontSize: 12.sp,
                    textAlign: TextAlign.center,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
