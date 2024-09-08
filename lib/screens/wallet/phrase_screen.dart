import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/profile/profile_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class WalletPhraseScreen extends StatefulWidget {
  const WalletPhraseScreen({super.key});

  @override
  State<WalletPhraseScreen> createState() => _WalletPhraseScreenState();
}

class _WalletPhraseScreenState extends State<WalletPhraseScreen> {
  List<String>? seedPhrase;

  void setMap() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    setState(() {
      seedPhrase = walletProvider.mnemonic!.split(' ');
    });
    //beepoPrint(seedPhrase);
  }

  @override
  void initState() {
    setMap();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // String seedArr = seedPhrase;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.h,
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: AppText(
          text: "Your Secret Phrase",
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.secondaryColor,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppText(
                  text:
                      "Please make sure to keep this secret phrase in a safe and secure location, as it is the only way to recover your account. Do not share this phrase with anyone, as it will grant them access to your account.\n",
                  color: AppColors.secondaryColor,
                  fontSize: 12.sp,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 35.h),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 30,
                    childAspectRatio: 3,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: const Color(0x72ff9b33),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.h,
                      ),
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        text: "${index + 1}. ${seedPhrase?[index]}",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                  itemCount: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
                SizedBox(height: 35.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0x99ffd1d1),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 20.h,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "Do not share this phrase with anyone, as it will grant them access to your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xff680e00),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Write Down your Seed Phrase in a Secured Place, \nThe Beepo Team will Never ask for it",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xff680e00),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                BeepoFilledButtons(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ProfileScreen();
                    }));
                  },
                  text: "I have written it down",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
