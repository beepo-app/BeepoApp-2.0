import 'package:Beepo/Constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BeepoFilledButtons extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final bool disabled;
  final Color? disabledColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;

  const BeepoFilledButtons({
    super.key,
    required this.text,
    this.color,
    required this.onPressed,
    this.disabled = false,
    this.disabledColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        height: height ?? 30.h,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 22),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: disabled
                  ? Colors.white.withOpacity(0.5)
                  : textColor ?? Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
