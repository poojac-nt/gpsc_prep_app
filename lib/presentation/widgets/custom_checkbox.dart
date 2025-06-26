import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_constants.dart';
class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({super.key, required this.value, required this.title});
  final bool value;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (value) {},
          fillColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return Colors.black;
            }
            return Colors.white;
          }),
          checkColor: Colors.white,
        ),
        Text(title, style: AppTexts.labelTextStyle.copyWith(fontSize: 13.sp)),
      ],
    );
  }
}