import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/extensions/padding.dart';
import '../../../widgets/pie_chart.dart';
import 'icon_container.dart';

class PerformanceCard extends StatelessWidget {
  const PerformanceCard({super.key});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Performance",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  5.hGap,
                  Text(
                    "Your learning curve",
                    style: TextStyle(color: Colors.black54, fontSize: 14.sp),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Detailed",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.navigate_next, color: Colors.blue),
                  ],
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
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  height: 150.h,
                  width: 150.h,
                  child: Stack(
                    children: [
                      CustomPieChart(
                        height: 150.h,
                        isLabelVisible: false,
                        centerSpaceValue: 3.5,
                        sectionRadiusMultiplier: 0.05,
                        total: 100,
                        itemOne: 30,
                        itemTwo: 30,
                        colorOne: AppColors.primary,
                        colorTwo: Colors.grey.shade300,
                        labelOne: "labelOne",
                        labelTwo: "labelTwo",
                      ),
                      Center(
                        heightFactor: 2.5.h,
                        child: Text(
                          "Accuracy\n42%",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.wGap,
              Expanded(
                flex: 1,
                child: TotalTestCard(
                  color: Colors.grey,
                  titleOne: "20/50",
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
      padding: EdgeInsets.all(20),
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
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          3.hGap,
          Text(
            titleTwo,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
