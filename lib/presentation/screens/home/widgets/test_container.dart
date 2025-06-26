import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
      child: Column(
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
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
          10.hGap,
          ActionButton(text: buttonTitle, onTap: () {}),
        ],
      ),
    );
  }
}
