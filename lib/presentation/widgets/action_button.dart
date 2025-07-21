import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor = const Color(0xff3b82f6),
    this.isLoading = false,
    this.fontColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
  });

  final String text;
  final VoidCallback onTap;
  final Color fontColor;
  final Color backgroundColor;
  final bool isLoading;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Skeleton.shade(
      child: SizedBox(
        width: double.infinity,
        height: 45.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? Colors.grey : backgroundColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadius,
              side: BorderSide(
                color: isLoading ? Colors.grey : backgroundColor,
                width: 1,
              ),
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
      ),
    );
  }
}
