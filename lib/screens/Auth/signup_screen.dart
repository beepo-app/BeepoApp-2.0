import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/outline_button.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/Auth/login_screen.dart';
import 'package:Beepo/screens/Auth/pin_code.dart';
import 'package:Beepo/screens/auth/create_acct_screen.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const Spacer(),
              Image.asset(
                'assets/login.png',
                height: 250.h,
                width: 250.w,
              ),
              // const Spacer(),
              BeepoFilledButtons(
                text: 'Create Account',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAccountScreen(),
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              BeepoFilledButtons(
                text: 'Import Wallet',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                ),
              ),
              SizedBox(height: 33.h),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 70,
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(height: 18.h),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "or",
                    style: TextStyle(
                      color: const Color(0x4c0e014c),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 70,
                  height: 1,
                  color: Colors.black,
                ),
              ]),
              SizedBox(height: 10.h),
              OutlnButton(
                icon: SvgPicture.asset('assets/google.svg'),
                text: 'Continue with Google',
                onPressed: () async {
                  try {
                    debugPrint("Authenticating with Google...");

                    debugPrint("Initializing platform state");
                    await walletProvider.initPlatformState();
                    debugPrint("Platform state initialized");

                    debugPrint("Attempting Web3Auth login");
                    final authResult = await walletProvider.web3AuthLogin();
                    debugPrint("Web3Auth login result: $authResult");

                    if (authResult == null || authResult['error'] != null) {
                      throw Exception(
                          authResult?['error'] ?? "Authentication failed");
                    }

                    debugPrint("Initializing MPC wallet state");
                    await walletProvider.initMPCWalletState(authResult);
                    debugPrint(
                        "MPC wallet state initialized. ETH Address: ${walletProvider.ethAddress}");

                    if (walletProvider.ethAddress == null) {
                      throw Exception("Wallet initialization failed");
                    }

                    // Fetch user from Firebase
                    debugPrint("Fetching user from Firebase");
                    final FirebaseFirestore firestore =
                        FirebaseFirestore.instance;
                    final userDoc = await firestore
                        .collection('users')
                        .doc(walletProvider.ethAddress.toString())
                        .get();

                    if (userDoc.exists) {
                      final userData = userDoc.data() as Map<String, dynamic>;
                      debugPrint("User found in Firebase");
                      Get.to(
                        () => PinCode(
                          data: {'response': userData, 'mpc': authResult},
                          isSignedUp: false,
                        ),
                      );
                    } else {
                      debugPrint(
                          "No matching user found. Navigating to CreateAccountScreen");
                      Get.to(() => const CreateAccountScreen());
                    }
                  } catch (e) {
                    debugPrint("Error during sign-in process: $e");
                    showToast("An error occurred: ${e.toString()}");
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
