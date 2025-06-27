import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backColor = Colors.black,
    this.fontColor = Colors.white,
    this.borderColor = Colors.black,
    this.padding = const EdgeInsets.all(10),
  });

  final String text;
  final VoidCallback onTap;
  final Color backColor;
  final Color fontColor;
  final Color borderColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadius,
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: fontColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
