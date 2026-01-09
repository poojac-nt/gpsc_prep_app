import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';

class GoalReminderCard extends StatelessWidget {
  const GoalReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPaddings.dashboardContainerPadding),
      decoration: BoxDecoration(
        borderRadius: AppBorders.dashboardBorderRadius,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Goal reminder
          Row(
            children: [
              Icon(Icons.flag, size: 16.sp, color: Colors.white70),
              7.wGap,
              Text(
                "GOAL REMINDER",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          5.hGap,
          Text(
            "Attempt 1 test today",
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          8.hGap,
          Text(
            "Consistency is the key to cracking Mains",
            style: TextStyle(color: Colors.white60),
          ),
          18.hGap,

          ///Weekly Consistency
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: AppBorders.dashboardBorderRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, size: 18.sp, color: Colors.white),
                8.wGap,
                Text(
                  "Weekly Consistency",
                  style: TextStyle(color: Colors.white),
                ),
                Spacer(),
                Row(
                  children: List.generate(7, (index) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 7.w,
                      ),
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        color:
                            index > 3
                                ? Colors.white.withAlpha(70)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
