import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.controller,
    this.isLoading = false,
    this.maxLine = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final int maxLine;
  final bool isLoading;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      maxLines: maxLine,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        isDense: true,
        enabled: !isLoading,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        prefixIconColor: Colors.grey.shade700,
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius,
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
      ),
      cursorColor: Colors.black,
      keyboardType: keyboardType,
    );
  }
}
