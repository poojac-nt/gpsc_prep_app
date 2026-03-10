import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class ScoreInputTile extends StatelessWidget {
  final String questionLabel;
  final String? subject;
  final int maxMarks;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isError;
  final String? errorMessage;

  const ScoreInputTile({
    super.key,
    required this.questionLabel,
    this.subject,
    required this.maxMarks,
    this.controller,
    this.onChanged,
    this.isError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: isError ? 4.h : 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isError ? Colors.red[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isError ? Colors.red[300]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Question info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionLabel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (subject != null)
                      Text(
                        subject!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              // Score input
              SizedBox(
                width: 50.w,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isError ? Colors.red[700] : AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: isError ? Colors.red[300]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: isError ? Colors.red[700]! : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  cursorColor: isError ? Colors.red : AppColors.primary,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '/ $maxMarks',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: isError ? Colors.red[700] : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (isError && errorMessage != null)
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 11.sp),
            ),
          ),
      ],
    );
  }
}
