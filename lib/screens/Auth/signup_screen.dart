import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/outline_button.dart';
import 'package:Beepo/constants/constants.dart';
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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      debugPrint("Authenticating with Google...");

      // Initialize platform state
      await walletProvider.initPlatformState();
      debugPrint("Platform state initialized");

      // Perform Web3Auth login
      final authResult = await walletProvider.web3AuthLogin();
      debugPrint("Web3Auth login result: $authResult");

      if (authResult == null || authResult['error'] != null) {
        throw Exception(authResult?['error'] ?? "Authentication failed");
      }

      // Initialize MPC wallet state
      await walletProvider.initMPCWalletState(authResult);
      debugPrint(
          "MPC wallet state initialized. ETH Address: ${walletProvider.ethAddress}");

      if (walletProvider.ethAddress == null) {
        throw Exception("Wallet initialization failed");
      }

      // Fetch user from Firebase
      debugPrint("Fetching user from Firebase");
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final userDoc = await firestore
          .collection('users')
          .doc(walletProvider.ethAddress.toString())
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        debugPrint("User found in Firebase");

        // Extract Google profile data
        final googleProfile = authResult['userInfo'];
        final displayName = googleProfile['name'];
        final photoUrl = googleProfile['profileImage'];

        // Store user data in Hive
        await _storeUserDataInHive({
          ...userData,
          'displayName': displayName,
          'imageUrl': photoUrl,
        });

        // Set isSignedUp to true
        await Hive.box('Beepo2.0').put('isSignedUp', true);

        debugPrint("STORE USER DATAS: $userData");

        Get.to(
          () => PinCode(
            data: {'response': userData, 'mpc': authResult},
            isSignedUp: true,
          ),
        );
      } else {
        debugPrint("No matching user found. Navigating to CreateAccountScreen");

        // Extract Google profile data
        final googleProfile = authResult['userInfo'];
        final displayName = googleProfile['name'];
        final photoUrl = googleProfile['profileImage'];

        // Store Google profile data in Hive
        await _storeUserDataInHive({
          'displayName': displayName,
          'imageUrl': photoUrl,
          'ethAddress': walletProvider.ethAddress,
        });

        // Set isSignedUp to true
        await Hive.box('Beepo2.0').put('isSignedUp', true);

        Get.to(() => const CreateAccountScreen());
      }
    } catch (e) {
      debugPrint("Error during sign-in process: $e");
      showToast("An error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Store user data in Hive
  Future<void> _storeUserDataInHive(Map<String, dynamic> userData) async {
    try {
      final box = Hive.box('Beepo2.0');
      await box.put('username', userData['username'] ?? "Unknown");
      await box.put('displayName', userData['displayName'] ?? "Unknown");
      await box.put('ethAddress', userData['ethAddress'] ?? "Unknown");
      await box.put('imageUrl', userData['imageUrl'] ?? "");
      debugPrint("User data stored in Hive successfully");
    } catch (e) {
      debugPrint("Error storing user data in Hive: $e");
      showToast("Failed to store user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/login.png',
                    height: 250.h,
                    width: 250.w,
                  ),
                  SizedBox(height: 40.h),
                  BeepoFilledButtons(
                    text: 'Create Account',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BeepoFilledButtons(
                    text: 'Import Wallet',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 1,
                          indent: 20.w,
                          endIndent: 10.w,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: const Color(0x4c0e014c),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 1,
                          indent: 10.w,
                          endIndent: 20.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: OutlnButton(
                      icon: SvgPicture.asset('assets/google.svg'),
                      text: 'Continue with Google',
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      disabled: _isLoading,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
