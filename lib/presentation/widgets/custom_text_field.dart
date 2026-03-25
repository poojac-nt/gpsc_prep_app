import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.isLoading = false,
    this.isPassword = false,
    this.maxLine = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final int maxLine;
  final bool isLoading;
  final bool isPassword;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Skeleton.shade(
      child: TextFormField(
        validator: validator,
        controller: controller,
        maxLines: maxLine,
        obscureText: isPassword ? true : false,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: Colors.grey[50], // Very subtle background
          filled: true,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          isDense: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          enabled: !isLoading,
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon:
              prefixIcon != null
                  ? Icon(prefixIcon, size: 20.sp, color: Colors.grey[600])
                  : null,
          suffixIcon: suffixIcon,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red[300]!, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[100]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        cursorColor: Colors.black,
        keyboardType: keyboardType,
      ),
    );
  }
}
