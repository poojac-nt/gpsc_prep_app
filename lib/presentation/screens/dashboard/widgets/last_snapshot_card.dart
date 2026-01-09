import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import 'custom_progress_bar.dart';
import 'icon_container.dart';

class LastSnapshotCard extends StatelessWidget {
  const LastSnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppPaddings.dashboardContainerPadding),
      decoration: BoxDecoration(
        borderRadius: AppBorders.dashboardBorderRadius,
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconContainer(
                borderRadius: BorderRadius.circular(10.r),
                icon: Icons.watch_later_outlined,
                color: Colors.black26,
              ),
              10.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Test Snapshot",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    3.hGap,
                    Text(
                      "MCQ or Mains",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "142",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextSpan(
                      text: "/200",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 15.hGap,
          CustomProgressBar(
            titleText: '',
            value: 0.7,
            labelText: '',
            minHeight: 10,
          ),
          15.hGap,
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              borderRadius: AppBorders.dashboardBorderRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: AppColors.primary),
                10.wGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Improvement Tip",
                        style: TextStyle(color: AppColors.primary),
                      ),
                      RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Focus more on ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextSpan(
                              text: "History",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " in next attempts to improve your overall score",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
