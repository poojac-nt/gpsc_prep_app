import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../domain/entities/dashboard_analytics.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import '../../../../utils/improvement_tips.dart';
import 'custom_progress_bar.dart';
import 'dashboard_container.dart';
import 'icon_container.dart';

class LastSnapshotCard extends StatelessWidget {
  final LastTest? lastTest;

  const LastSnapshotCard({super.key, required this.lastTest});
  int get totalMarks => (lastTest?.score ?? 0).toInt();
  int get obtainedMarks => (lastTest?.gainedScore ?? 0).toInt();

  @override
  Widget build(BuildContext context) {
    return DashboardContainer(
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
                      style: AppTexts.dashboardMediumTitle,
                    ),
                    3.hGap,
                    Text(
                      lastTest?.testName ?? 'No test attempted',
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: AppTexts.dashboardSmallTexts,
                    ),
                  ],
                ),
              ),
              3.wGap,
              Tooltip(
                message: "$obtainedMarks out of $totalMarks marks",
                child: RichText(
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
          lastTest?.weakAreas != null
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
                            softWrap: true,
                            text: TextSpan(
                              children:
                                  ImprovementTipsProvider.getDeterministicImprovementTip(
                                    subject: lastTest?.weakAreas?.subject ?? "",
                                    questionType:
                                        lastTest?.weakAreas?.questionType ?? "",
                                    difficulty:
                                        lastTest?.weakAreas?.difficultyLevel ??
                                        "",
                                    testId: lastTest?.testId,
                                    normalStyle: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                    highlightStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
