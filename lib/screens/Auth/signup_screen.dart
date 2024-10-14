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
import 'package:get/get_utils/src/extensions/export.dart';
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
                  List? users = Hive.box('Beepo2.0').get('allUsers');

                  // await accountProvider.getAllUsers();
                  await walletProvider.initPlatformState();
                  Map? res = await walletProvider.web3AuthLogin();

                  // ignore: unnecessary_null_comparison
                  if (res != null && res['error'] == null) {
                    loadingDialog("Checking Info!");

                    users = Hive.box('Beepo2.0').get('allUsers');
                    if (users == null) {
                      Future.delayed(const Duration(seconds: 5));
                    }

                    users = Hive.box('Beepo2.0').get('allUsers');
                    if (users == null) {
                      Future.delayed(const Duration(seconds: 5));
                      await accountProvider.getAllUsers();
                    }

                    users = Hive.box('Beepo2.0').get('allUsers');
                    if (users == null) {
                      Future.delayed(const Duration(seconds: 5));
                    }

                    users = Hive.box('Beepo2.0').get('allUsers');
                    if (users == null) {
                      Future.delayed(const Duration(seconds: 5));
                    }

                    users = Hive.box('Beepo2.0').get('allUsers');
                    if (users == null) {
                      Future.delayed(const Duration(seconds: 5));
                      Navigator.pop(context);
                      showToast("An error Occured, Please Try Again!");
                      return;
                    }

                    await walletProvider.initMPCWalletState(res);
                    if (walletProvider.ethAddress != null) {
                      // users = await Hive.box('Beepo2.0').get('allUsers');
                      var newRes = users.firstWhereOrNull((e) =>
                          e['ethAddress'] ==
                          walletProvider.ethAddress.toString());

                      if (newRes == null) {
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
                              data: {'response': newRes, 'mpc': res},
                              isSignedUp: false,
                            ),
                          ));

                      return;
                    }
                    return;
                  }
                  showToast("An error Occured, Please Try Again!");
                },
              ),
              // SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}
