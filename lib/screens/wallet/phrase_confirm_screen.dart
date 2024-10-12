import 'package:Beepo/Utils/styles.dart';
import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/screens/wallet/phrase_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class PhraseConfirmationScreen extends StatefulWidget {
  const PhraseConfirmationScreen({super.key});

  @override
  State<PhraseConfirmationScreen> createState() =>
      _PhraseConfirmationScreenState();
}

class _PhraseConfirmationScreenState extends State<PhraseConfirmationScreen> {
  bool value1 = false;
  bool value2 = false;
  bool value3 = false;
  bool value4 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.h,
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: AppText(
          text: "Secret Phrase",
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.secondaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              Text(
                "In the next step, you will be given a \"Secret Phrase\" of 12 words to secure your account. Keep it safe and confidential, as it's the only way to recover your account. Sharing the phrase will grant access to your account to others.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Lottie.asset(
                'assets/lottie/security.json',
                height: 200,
                width: 200,
              ),
              SizedBox(height: 18.h),
              CheckboxListTile(
                value: value1,
                onChanged: (value) {
                  setState(() {
                    value1 = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  "If I lose my secret phrase, my assets and Beepo account will be lost forever.",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              CheckboxListTile(
                value: value2,
                onChanged: (value) {
                  setState(() {
                    value2 = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  "If I expose or share my secret phrase to anybody, my assets can get stolen.",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              CheckboxListTile(
                value: value3,
                onChanged: (value) {
                  setState(() {
                    value3 = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  "I agree that the Beepo App and Beepo Inc. team will NEVER reach out to ask for it.",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              CheckboxListTile(
                value: value4,
                onChanged: (value) {
                  setState(() {
                    value4 = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  "The Beepo app is user centric and decentralized therefore I am responsible for the security and protection of my Beepo account and assets within",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              BeepoFilledButtons(
                text: "Proceed",
                onPressed: () {
                  if (value1 == true &&
                      value2 == true &&
                      value3 == true &&
                      value4 == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletPhraseScreen(),
                      ),
                    );
                  } else {
                    showToast('Kindly select all aptions!');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
