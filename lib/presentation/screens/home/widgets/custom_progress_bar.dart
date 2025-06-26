import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({
    super.key,
    required this.text,
    required this.value,
    required this.percentageText,
  });

  final String text;
  final String percentageText;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(percentageText),
          ],
        ),
        5.hGap,
        LinearProgressIndicator(
          value: value,
          minHeight: 6.h,
          backgroundColor: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ],
    );
  }
}
