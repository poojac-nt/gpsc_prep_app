import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.text,
    this.prefixIcon,
    this.controller,
    this.maxline = 1,
  });

  final String text;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final int maxline;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxline,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(color: Colors.grey),
        isDense: true,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        prefixIconColor: Colors.grey.shade700,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      cursorColor: Colors.black,
    );
  }
}
