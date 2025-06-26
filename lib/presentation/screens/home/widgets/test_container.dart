import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

import '../../../widgets/action_button.dart';

class TestContainer extends StatelessWidget {
  const TestContainer({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonTitle,
    required this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final String buttonTitle;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 36.sp, color: iconColor),
        15.hGap,
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        5.hGap,
        Text(
          description,
          textAlign: TextAlign.center,
          // style: AppTexts.descriptionTextStyle,
        ),
        10.hGap,
        ActionButton(text: buttonTitle, onTap: () {}),
      ],
    );
  }
}
