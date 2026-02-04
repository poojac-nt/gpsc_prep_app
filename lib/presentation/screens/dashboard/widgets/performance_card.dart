import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import '../../../widgets/pie_chart.dart';
import 'dashboard_container.dart';
import 'icon_container.dart';

class PerformanceCard extends StatelessWidget {
  final double accuracy;
  final int totalTest;
  final int completedTest;

  const PerformanceCard({
    super.key,
    required this.accuracy,
    required this.totalTest,
    required this.completedTest,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardContainer(
      padding: EdgeInsets.only(
        left: AppPaddings.dashboardContainerPadding,
        right: AppPaddings.dashboardContainerPadding,
        top: 25.h,
        bottom: 25.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Performance", style: AppTexts.dashboardContainerTitle),
                  5.hGap,
                  Text(
                    "Your learning curve",
                    style: AppTexts.dashboardSmallTexts,
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 4.w,
                  top: 3.h,
                  bottom: 3.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: AppBorders.dashboardBorderRadius,
                ),
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.analyticsScreen),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Detailed",
                        style: AppTexts.dashboardSmallTexts.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.navigate_next, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
          20.hGap,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxHeight.clamp(150.0, 180.0);
                    return Container(
                      padding: EdgeInsets.only(top: 4.h),
                      width: size,
                      child: CustomPieChart(
                        height: size,
                        isLabelVisible: false,
                        centerSpaceValue: 3.5,
                        sectionRadiusMultiplier: 0.05,
                        total: 100,
                        itemOne: accuracy.toInt(),
                        itemTwo: 100,
                        colorOne: AppColors.primary,
                        colorTwo: Colors.grey.shade300,
                        startDegreeOffset: -90,
                        centerWidget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Accuracy",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${accuracy.toStringAsFixed(2)}%",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              20.wGap,
              Expanded(
                flex: 1,
                child: TotalTestCard(
                  color: Colors.grey,
                  titleOne: "$completedTest/$totalTest",
                  titleTwo: "Test Completed",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TotalTestCard extends StatelessWidget {
  final Color color;
  final String titleOne;
  final String titleTwo;
  final Icon? icon;

  const TotalTestCard({
    super.key,
    required this.color,
    required this.titleOne,
    required this.titleTwo,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: AppBorders.dashboardBorderRadius,
        border: Border.all(color: color, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconContainer(
            borderRadius: BorderRadius.circular(100.r),
            icon: Icons.fact_check_rounded,
            color: AppColors.primary,
          ),
          15.hGap,
          Text(
            titleOne,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          3.hGap,
          Text(
            titleTwo,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: AppTexts.dashboardSmallTexts,
          ),
        ],
      ),
    );
  }
}
