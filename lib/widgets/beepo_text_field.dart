import 'package:Beepo/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BeepoTextField extends StatelessWidget {
  final Widget? suffixIcon;
  final Icon? prefixIcon;
  final String? hintText;
  final bool? filled;
  final TextEditingController? controller;
  const BeepoTextField({
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.controller,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color(0xff0e014c),
      decoration: InputDecoration(
        hintText: hintText,
        filled: filled,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        fillColor: AppColors.backgroundGrey,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          borderRadius: BorderRadius.all(
            Radius.circular(10.r),
          ),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
