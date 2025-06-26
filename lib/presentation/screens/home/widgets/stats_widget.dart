import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.num,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String num;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 34.sp),
          5.wGap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                num,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
