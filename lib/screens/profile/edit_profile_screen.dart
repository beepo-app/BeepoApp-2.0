import 'dart:convert';
import 'dart:typed_data';

import 'package:Beepo/components/Beepo_filled_button.dart';
import 'package:Beepo/providers/account_provider.dart';
import 'package:Beepo/utils/functions.dart';
import 'package:Beepo/widgets/app_text.dart';
import 'package:Beepo/widgets/Beepo_text_field.dart';
import 'package:Beepo/widgets/commons.dart';
import 'package:Beepo/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const EditProfileScreen({super.key, required this.imageBytes});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController displayName = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController bio = TextEditingController();
  Uint8List? selectedImage;

  @override
  Widget build(BuildContext context) {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.h,
        centerTitle: true,
        backgroundColor: AppColors.secondaryColor,
        title: AppText(
          text: "Edit Profile",
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
          color: AppColors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: 131,
                      height: 131,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffc4c4c4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: selectedImage != null
                            ? Image.memory(
                                selectedImage!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.memory(
                                widget.imageBytes,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = null;
                          });
                          ImageUtil()
                              .pickProfileImage(context: context)
                              .then((value) async {
                            if (value != null) {
                              setState(() {
                                selectedImage = value;
                              });
                            }
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryColor,
                          ),
                          child: const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              AppText(
                text: "Display name",
                color: AppColors.secondaryColor,
                fontSize: 16.sp,
              ),
              AppText(
                text: "Your display name can only be edit once in 30days",
                color: AppColors.secondaryColor,
                fontSize: 10.sp,
              ),
              SizedBox(height: 10.h),
              BeepoTextField(
                hintText: 'Enter your display name',
                controller: displayName,
              ),
              SizedBox(height: 20.h),
              AppText(
                text: "Username",
                color: AppColors.secondaryColor,
                fontSize: 16.sp,
              ),
              AppText(
                text: "Your username can only be edit once in every 6months",
                color: AppColors.secondaryColor,
                fontSize: 10.sp,
              ),
              SizedBox(height: 10.h),
              BeepoTextField(
                hintText: 'Enter your username',
                controller: userName,
              ),
              SizedBox(height: 20.h),
              AppText(
                text: "Bio",
                color: AppColors.secondaryColor,
                fontSize: 16.sp,
              ),
              AppText(
                text: "Max 100 Characters",
                color: AppColors.secondaryColor,
                fontSize: 10.sp,
              ),
              SizedBox(height: 10.h),
              BeepoTextField(
                hintText: 'Enter your username',
                controller: bio,
              ),
              SizedBox(height: 35.h),
              Center(
                child: BeepoFilledButtons(
                  text: "Save",
                  onPressed: () async {
                    if (displayName.text != "" &&
                        bio.text != "" &&
                        userName.text != '') {
                      if (bio.text.length > 100) {
                        showToast('Bio has more than 100 characters');
                        return;
                      }
                      if (userName.text.length < 3 ||
                          displayName.text.length < 3) {
                        showToast(
                            'Username or display Text should be greater than 3 characters');
                        return;
                      }
                      loadingDialog('Updating Profile ..');
                      Map userdata = await accountProvider.updateUser(
                          base64Encode(selectedImage ?? widget.imageBytes),
                          // accountProvider.db,
                          displayName.text,
                          bio.text,
                          userName.text);
                      if (userdata['error'] != null) {
                        Navigator.pop(context);

                        showToast('Username Already exists!');
                        return;
                      }
                      if (userdata['success']['username'] == userName.text) {
                        Navigator.pop(context);
                        await accountProvider.initAccountState();

                        showToast('Profile Updated Successfully!');
                      }
                    } else {
                      showToast('Please Enter All Fields!');
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
