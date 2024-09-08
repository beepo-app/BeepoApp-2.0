import 'package:Beepo/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletIcon extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
  final double? angle;
  const WalletIcon({
    Key? key,
    this.text,
    this.icon,
    this.onTap,
    this.angle = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 3.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50.h,
            width: 70.w,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            color: AppColors.secondaryColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: angle!,
                    child: Icon(
                      icon,
                      size: 25,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  FittedBox(
                    child: Text(
                      text!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
