import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
