import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlnButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback? onPressed;
  final bool disabled;

  const OutlnButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 30.h,
        decoration: BoxDecoration(
          color: disabled ? Colors.grey : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: disabled ? Colors.grey : Colors.black),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: disabled ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
