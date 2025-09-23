import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class QuestionPieChart extends StatelessWidget {
  final int height;

  final int correct;
  final int incorrect;

  const QuestionPieChart({
    super.key,

    this.height = 200,
    required this.correct,
    required this.incorrect,
  });

  @override
  Widget build(BuildContext context) {
    final total = correct + incorrect;
    final centerSpace = height / 3;
    final sectionRadius = height * 0.2; // 40% of height

    return TestModule(
      title: "Performance Breakdown",
      cards: [
        SizedBox(
          height: height.h,
          width: double.maxFinite,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: centerSpace,
              borderData: FlBorderData(show: false),
              sections: [
                PieChartSectionData(
                  value: correct.toDouble(),
                  showTitle: false,
                  // remove text inside chart
                  color: Colors.green,
                  radius: sectionRadius.sp,
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                PieChartSectionData(
                  value: incorrect.toDouble(),
                  showTitle: false,
                  // remove text inside chart
                  color: Colors.red,
                  radius: sectionRadius.sp,
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        20.hGap,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: Colors.green,
              text: 'Correct: ${(correct / total * 100).toStringAsFixed(1)}%',
            ),
            SizedBox(width: 20.w),
            _buildLegendItem(
              color: Colors.red,
              text:
                  'Incorrect: ${(incorrect / total * 100).toStringAsFixed(1)}%',
            ),
          ],
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
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
