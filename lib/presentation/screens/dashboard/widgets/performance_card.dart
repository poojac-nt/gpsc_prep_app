import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import '../../../widgets/pie_chart.dart';
import 'dashboard_container.dart';

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
                        itemTwo: 100 - accuracy.toInt(),
                        colorOne: AppColors.primary,
                        colorTwo: Colors.grey.shade300,
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
                  completed: completedTest,
                  total: totalTest,
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
  final int completed;
  final int total;

  const TotalTestCard({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  "TOTAL $total",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          15.hGap,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$completed",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B), // Slate 800
                  height: 1.0,
                ),
              ),
              4.hGap,
              Text(
                "TESTS\nCOMPLETED",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B), // Slate 500
                  letterSpacing: 0.8,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AccuracyCard extends StatelessWidget {
  final double accuracy;

  const AccuracyCard({super.key, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Very light grey/blue
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: SizedBox(
          height: 120.h,
          width: 120.h,
          child: CustomPieChart(
            height: 120.h,
            isLabelVisible: false,
            centerSpaceValue: 3.5,
            sectionRadiusMultiplier: 0.05,
            total: 100,
            itemOne: accuracy.toInt(),
            itemTwo: 100 - accuracy.toInt(),
            colorOne: AppColors.primary,
            colorTwo: Colors.grey.shade300,
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
        ),
      ),
    );
  }
}
