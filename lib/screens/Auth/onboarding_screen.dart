import 'package:Beepo/screens/Auth/signup_screen.dart';
import 'package:Beepo/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Utils/styles.dart';
import "package:lottie/lottie.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int check = 0;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> body = [
    {
      'image': 'assets/onboard1.png',
      'text':
          'Beepo  is a decentralized social media platform that prioritizes anonymity with small-scale business capabilities.'
    },
    {
      'image': 'assets/onboard2.png',
      'text':
          'Beepo enables seamless communication and media sharing with family and friends using an enhanced E2EE protocol.'
    },
    {
      'image': 'assets/onboard3.png',
      'text':
          'Beepo is designed to meet the needs of small scale business owners and freelancers for secured and decentralized transactions'
    }
  ];

  List titles = [
    "Welcome to Beepo",
    "E2EE Security",
    "Scale Your Business",
  ];

  List lotties = [
    'assets/lottie/lott_2.json',
    'assets/lottie/lott_3.json',
    'assets/lottie/lott_4.json',
    'assets/lottie/lottie_1.json',
  ];

  // static get image => null;
  @override
  Widget build(BuildContext context) {
    beepoPrint('object');
    beepoPrint('object');
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: bg,
            padding: const EdgeInsets.all(21),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    onPageChanged: (int index) {
                      setState(() {
                        check = index;
                      });
                    },
                    itemCount: body.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          const Spacer(),
                          Lottie.asset(lotties[index]),
                          SizedBox(height: 28.h),
                          Text(
                            titles[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            body[index]['text']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 30.h,
                  child: TextButton(
                    onPressed: () {
                      if (check == body.length - 1) {
                        Get.to(() => const SignUp());
                      } else {
                        controller.animateToPage(
                          check + 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                      controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        check == body.length - 1
                            ? secondaryColor
                            : primaryColor,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                    child: Text(
                      check == body.length - 1 ? 'Completed' : 'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
