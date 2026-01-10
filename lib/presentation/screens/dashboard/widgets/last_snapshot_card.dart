import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/entities/dashboard_analytics.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import 'custom_progress_bar.dart';
import 'icon_container.dart';

class LastSnapshotCard extends StatelessWidget {
  final LastTest? lastTest;

  const LastSnapshotCard({super.key, required this.lastTest});
  int get totalMarks => (lastTest?.score ?? 0).toInt();
  int get obtainedMarks => (lastTest?.gainedScore ?? 0).toInt();

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
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    3.hGap,
                    Text(
                      lastTest?.testName ?? 'No test attempted',
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              3.wGap,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$obtainedMarks",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextSpan(
                      text: "/$totalMarks",
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
            value:
                totalMarks <= 0
                    ? 0.0
                    : (obtainedMarks / totalMarks).clamp(0.0, 1.0),
            labelText: '',
            minHeight: 10,
          ),
          15.hGap,
          lastTest != null
              ? Container(
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
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
