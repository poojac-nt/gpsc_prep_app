import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class CustomPieChart extends StatelessWidget {
  final double height;
  final int total;
  final int itemOne;
  final int itemTwo;
  final Color colorOne;
  final Color colorTwo;
  final String labelOne;
  final String labelTwo;

  const CustomPieChart({
    super.key,
    required this.total,
    this.height = 180,
    required this.itemOne,
    required this.itemTwo,
    required this.colorOne,
    required this.colorTwo,
    required this.labelOne,
    required this.labelTwo,
  });

  @override
  Widget build(BuildContext context) {
    final centerSpace = height.h / 5;
    final sectionRadius = height.h * 0.11;

    if (total == 0) {
      return SizedBox(
        height: height.h,
        child: const Center(child: Text("No Data")),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: height.h * 0.7,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: centerSpace,
              borderData: FlBorderData(show: false),
              sections: [
                PieChartSectionData(
                  value: itemOne.toDouble(),
                  showTitle: false,
                  color: colorOne,
                  radius: sectionRadius.sp,
                ),
                PieChartSectionData(
                  value: itemTwo.toDouble(),
                  showTitle: false,
                  color: colorTwo,
                  radius: sectionRadius.sp,
                ),
              ],
            ),
          ),
        ),
        15.hGap,
        _buildLegendItem(
          color: colorOne,
          text: '$labelOne (${(itemOne / total * 100).toStringAsFixed(0)}%)',
        ),
        8.hGap,
        _buildLegendItem(
          color: colorTwo,
          text: '$labelTwo (${(itemTwo / total * 100).toStringAsFixed(0)}%)',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        10.wGap,
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
