import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({
    super.key,
    required this.titleText,
    required this.value,
    required this.labelText,
  });

  final String titleText;
  final String labelText;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                titleText,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Flexible(
              child: Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                labelText,
              ),
            ),
          ],
        ),
        5.hGap,
        LinearProgressIndicator(
          value: value,
          minHeight: 6.h,
          backgroundColor: Colors.grey.shade300,
          borderRadius: AppBorders.borderRadius,
        ),
      ],
    );
  }
}
