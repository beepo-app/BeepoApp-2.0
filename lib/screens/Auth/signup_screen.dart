import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/components/outline_button.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/providers/wallet_provider.dart';
import 'package:Beepo/screens/Auth/login_screen.dart';
import 'package:Beepo/screens/Auth/pin_code.dart';
import 'package:Beepo/screens/auth/create_acct_screen.dart';
import 'package:Beepo/widgets/commons.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
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
              OutlnButton(
                icon: SvgPicture.asset('assets/google.svg'),
                text: 'Continue with Google',
                onPressed: () async {
                  try {
                    // Show a loading dialog while we authenticate the user
                    loadingDialog("Authenticating with Google...");

                    // Initialize platform state (wallet or app-specific logic)
                    await walletProvider.initPlatformState();

                    // Perform Web3Auth login
                    Map<String, dynamic>? res =
                        await walletProvider.web3AuthLogin();

                    // If there's an error in the response, stop the process
                    if (res == null || res['error'] != null) {
                      Navigator.pop(context); // Close the loading dialog
                      showToast("Login failed, please try again!");
                      return;
                    }

                    // Now proceed to fetch users from Hive
                    var users = Hive.box('Beepo2.0').get('allUsers');

                    // If users are not available, wait and retry fetching them
                    if (users == null) {
                      loadingDialog("Fetching user data...");
                      await Future.delayed(const Duration(seconds: 3));
                      await accountProvider.getAllUsers();

                      users = Hive.box('Beepo2.0').get('allUsers');
                      if (users == null) {
                        Navigator.pop(context); // Close the dialog
                        showToast(
                            "Unable to retrieve user data. Please try again.");
                        return;
                      }
                    }

                    // Initialize wallet with the MPC response
                    await walletProvider.initMPCWalletState(res);

                    // If the wallet was initialized and there's an Ethereum address
                    if (walletProvider.ethAddress != null) {
                      var user = users.firstWhereOrNull(
                        (e) =>
                            e['ethAddress'] ==
                            walletProvider.ethAddress.toString(),
                      );

                      if (user == null) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PinCode(
                            data: {'response': user, 'mpc': res},
                            isSignedUp: false,
                          ),
                        ),
                      );
                      return;
                    } else {
                      Navigator.pop(context);
                      showToast("Wallet initialization failed.");
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    showToast("An error occurred: $e");
                  }
                },
              )
              // SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}
