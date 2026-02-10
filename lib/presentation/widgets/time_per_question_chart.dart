import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart'; // Wait, I might need this for AppColors or similar if I decide to use them later, but let's remove it for now if linter says so.

class TimePerQuestionChart extends StatelessWidget {
  final List<DetailedTestResult> results;

  const TimePerQuestionChart({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) return const SizedBox.shrink();

    final maxTime = results
        .map((e) => e.timeSpent)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxTime + 5).toDouble();

    return TestModule(
      title: "Time per Question (Seconds)",
      cards: [
        15.hGap,
        Container(
          height: 250.h,
          width: double.maxFinite,
          padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (results.length * 40.w).clamp(300.w, 5000.w),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: colorScheme.outline.withAlpha(25),
                          strokeWidth: 1,
                        ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                        width: 1,
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= results.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          );
                        },
                        reservedSize: 22.h,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30.w,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}s',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor:
                          (group) => colorScheme.surfaceContainerHighest,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'Q${groupIndex + 1}\n',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.toInt()} sec',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups:
                      results.asMap().entries.map((entry) {
                        final index = entry.key;
                        final result = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: result.timeSpent.toDouble(),
                              color:
                                  result.isCorrect
                                      ? Colors.green.withAlpha(180)
                                      : Colors.red.withAlpha(180),
                              width: 18.w,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4.r),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
