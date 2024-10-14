import 'dart:convert';
import 'dart:typed_data';

import 'package:Beepo/constants/constants.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/screens/profile/edit_profile_screen.dart';
import 'package:Beepo/screens/profile/user_profile_security_screen.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import 'about.dart';

//import '../../Utils/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: true);
    String img = Hive.box('Beepo2.0').get('base64Image');
    Uint8List imageBytes = base64Decode(img);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45.h,
        centerTitle: true,
        backgroundColor: AppColors.secondaryColor,
        title: Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: AppText(
            text: "My Profile",
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.memory(
                    imageBytes,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    text: accountProvider.displayName!,
                    color: const Color(0xffff9c34),
                    fontSize: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditProfileScreen(imageBytes: imageBytes);
                      }));
                    },
                    child: const Icon(
                      Icons.mode_edit_outlined,
                      color: Color(0xffff9c34),
                      size: 28,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Center(
                child: AppText(
                  text: "@${accountProvider.username!}",
                  color: AppColors.secondaryColor,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 40.h),
              InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) {
                  //       return const AccountTypeScreen();
                  //     },
                  //   ),
                  // );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: "Account Type",
                        fontSize: 14.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    AppText(
                      text: "Standard",
                      fontSize: 11.sp,
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: AppText(
                        text: "Theme",
                        fontSize: 14.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                  AppText(
                    text: "System Default",
                    fontSize: 11.sp,
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const UserProfileSecurityScreen();
                      },
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: AppText(
                          text: "Security",
                          fontSize: 14.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0x660e014c),
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const About()),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: "About",
                        fontSize: 14.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0x660e014c),
                      size: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: "Invite Friends",
                      fontSize: 14.sp,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0x660e014c),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
