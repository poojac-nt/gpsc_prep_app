import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.fontColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
  });

  final String text;
  final VoidCallback onTap;
  final Color fontColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadius,
            side: BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fontColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
