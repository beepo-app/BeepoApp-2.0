import 'package:Beepo/Constants/constants.dart';
import 'package:Beepo/screens/profile/profile_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const ProfileScreen();
                },
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.white,
          ),
        ),
        toolbarHeight: 60.h,
        backgroundColor: AppColors.secondaryColor,
        title: AppText(
          text: "My Profile",
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 15.h),
            AppText(
              text: "Account Type",
              color: AppColors.secondaryColor,
              fontSize: 14.sp,
            ),
            SizedBox(height: 15.h),
            AppText(
              text:
                  "Beepo allows users to create professional profiles with additional features such as product and service sales instantly from their direct messages. You can turn on or off the features listed below.",
              color: AppColors.secondaryColor,
              fontSize: 12.sp,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "Professional Account",
                  color: AppColors.secondaryColor,
                  fontSize: 14.sp,
                ),
                const Icon(
                  Icons.done,
                  color: AppColors.secondaryColor,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                text: "Standard Account",
                color: AppColors.secondaryColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
