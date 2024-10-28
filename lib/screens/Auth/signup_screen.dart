import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/outline_button.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/google_sign_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/Auth/login_screen.dart';
import 'package:Beepo/screens/Auth/pin_code.dart';
import 'package:Beepo/screens/auth/create_acct_screen.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    final googleProvider = Provider.of<GoogleSignProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

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
              // OutlnButton(
              //   icon: SvgPicture.asset('assets/google.svg'),
              //   text: 'Continue with Google',
              //   onPressed: () async {
              //     try {
              //       // Step 1: Show loading dialog
              //       loadingDialog("Authenticating with Google...");

              //       // Step 2: Perform Google sign-in using Firebase
              //       await googleProvider.signInWithGoogle();

              //       // Step 3: Check if Google login was successful
              //       if (googleProvider.errorMessage != null) {
              //         Navigator.pop(context); // Close the loading dialog
              //         showToast(googleProvider.errorMessage!);
              //         debugPrint(
              //             "Google Sign-In Error: ${googleProvider.errorMessage}");
              //         return;
              //       }

              //       debugPrint("Google Sign-In Successful");

              //       // Step 4: Initialize wallet (platform-specific state)
              //       await walletProvider.initPlatformState();
              //       debugPrint("Wallet Platform State Initialized");

              //       // Step 5: Fetch users from API and Hive
              //       loadingDialog("Fetching user data...");
              //       Map<String, dynamic> userData =
              //           await accountProvider.getAllUsers();
              //       debugPrint("User data fetched: $userData");

              //       // Step 6: Check if the user exists in the database
              //       String? userEmail = googleProvider.user?.email;
              //       debugPrint("Checking for user with email: $userEmail");

              //       List<dynamic> users = userData['data'] ?? [];
              //       var user = users.isNotEmpty
              //           ? users.firstWhereOrNull((e) => e['email'] == userEmail)
              //           : null;

              //       Navigator.pop(context); // Close loading dialog

              //       if (user == null) {
              //         debugPrint(
              //             "User not found. Redirecting to CreateAccountScreen.");
              //         // New user, redirect to create account screen
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => CreateAccountScreen(),
              //           ),
              //         );
              //       } else {
              //         debugPrint("User found. Redirecting to PinCode screen.");
              //         // Existing user, redirect to PIN code screen
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => PinCode(
              //               data: {'response': user},
              //               isSignedUp: false,
              //             ),
              //           ),
              //         );
              //       }
              //     } catch (e, stackTrace) {
              //       debugPrint("Exception caught: $e");
              //       debugPrint("Stack trace: $stackTrace");
              //       Navigator.pop(context); // Ensure loading dialog is closed
              //       showToast("An error occurred. Please try again.");
              //     }
              //   },
              // ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PinCode(
                            data: {'response': userData, 'mpc': authResult},
                            isSignedUp: false,
                          ),
                        ),
                      );
                    } else {
                      debugPrint(
                          "No matching user found. Navigating to CreateAccountScreen");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen()),
                      );
                    }
                  } catch (e) {
                    debugPrint("Error during sign-in process: $e");
                    showToast("An error occurred: ${e.toString()}");
                  }
                },
              ),

              // OutlnButton(
              //   icon: SvgPicture.asset('assets/google.svg'),
              //   text: 'Continue with Google',
              //   onPressed: () async {
              //     try {
              //       debugPrint("Authenticating with Google...");

              //       debugPrint("Initializing platform state");
              //       await walletProvider.initPlatformState();
              //       debugPrint("Platform state initialized");

              //       debugPrint("Attempting Web3Auth login");
              //       final authResult = await walletProvider.web3AuthLogin();
              //       debugPrint("Web3Auth login result: $authResult");

              //       if (authResult == null || authResult['error'] != null) {
              //         throw Exception(
              //             authResult?['error'] ?? "Authentication failed");
              //       }

              //       debugPrint("Initializing MPC wallet state");
              //       await walletProvider.initMPCWalletState(authResult);
              //       debugPrint(
              //           "MPC wallet state initialized. ETH Address: ${walletProvider.ethAddress}");

              //       if (walletProvider.ethAddress == null) {
              //         throw Exception("Wallet initialization failed");
              //       }

              //       // Fetch users
              //       debugPrint("Fetching users from local storage");
              //       var users = await Hive.box('Beepo2.0').get('allUsers');
              //       if (users == null) {
              //         debugPrint(
              //             "Users not found in local storage. Fetching from server");
              //         loadingDialog("Fetching user data...");
              //         final fetchedUsers = await accountProvider.getAllUsers();
              //         Navigator.pop(context);

              //         if (!fetchedUsers['success']) {
              //           throw Exception(
              //               fetchedUsers['error'] ?? "Failed to fetch users");
              //         }

              //         users =
              //             List<Map<String, dynamic>>.from(fetchedUsers['data']);
              //         debugPrint(
              //             "Users fetched from server. Count: ${users.length}");
              //         await Hive.box('Beepo2.0').put('allUsers', users);
              //         debugPrint("Users stored in local storage");
              //       } else {
              //         debugPrint(
              //             "Users found in local storage. Count: ${users.length}");
              //       }

              //       debugPrint(
              //           "Searching for matching user with ETH address: ${walletProvider.ethAddress}");
              //       final matchingUser = users.firstWhereOrNull(
              //         (user) =>
              //             user['ethAddress'] ==
              //             walletProvider.ethAddress.toString(),
              //       );

              //       Navigator.pop(context);

              //       if (matchingUser == null) {
              //         debugPrint(
              //             "No matching user found. Navigating to CreateAccountScreen");
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const CreateAccountScreen()),
              //         );
              //       } else {
              //         debugPrint(
              //             "Matching user found. Navigating to PinCode screen");
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => PinCode(
              //               data: {'response': matchingUser, 'mpc': authResult},
              //               isSignedUp: false,
              //             ),
              //           ),
              //         );
              //       }
              //     } catch (e) {
              //       debugPrint("Error during sign-in process: $e");
              //       Navigator.pop(context);
              //       showToast("An error occurred: ${e.toString()}");
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
