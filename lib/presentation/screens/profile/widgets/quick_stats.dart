import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_constants.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key, required this.text, required this.num});
  final String text;
  final String num;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: AppTexts.subTitle.copyWith(fontSize: 14.sp)),
        Text(
          num,
          style: AppTexts.subTitle.copyWith(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
