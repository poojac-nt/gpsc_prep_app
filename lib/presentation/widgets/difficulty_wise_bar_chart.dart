import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';

class DifficultyWiseBarChart extends StatelessWidget {
  final List<TestReviewByDifficulty> data;

  const DifficultyWiseBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY =
        data
            .map((e) => e.totalQuestionsInTest)
            .fold<int>(0, (a, b) => a > b ? a : b)
            .toDouble();

    return SizedBox(
      height: 300.h,
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          barTouchData: _barTouchData(),
          titlesData: _titlesData(),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey, width: 2.sp), // Y-axis
              bottom: BorderSide(color: Colors.grey, width: 2.sp), // X-axis
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          gridData: FlGridData(show: false),
          barGroups: _barGroups(),
        ),
      ),
    );
  }

  /// 🔹 Bars
  List<BarChartGroupData> _barGroups() {
    return List.generate(data.length, (index) {
      final item = data[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalQuestionsInTest.toDouble(),
            color: Colors.transparent,
            rodStackItems: [
              BarChartRodStackItem(
                0,
                item.correctCount.toDouble(),
                Colors.green,
              ),
              BarChartRodStackItem(
                item.correctCount.toDouble(),
                (item.correctCount + item.incorrectCount).toDouble(),
                Colors.red,
              ),
            ],
            width: 26,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(5.r),
              topLeft: Radius.circular(5.r),
            ),
          ),
        ],
      );
    });
  }

  /// 🔹 Tap Tooltip
  BarTouchData _barTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Colors.black87,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final item = data[group.x.toInt()];

          return BarTooltipItem(
            '${item.difficultyLevel.toUpperCase()}\n'
            'Correct: ${item.correctCount}\n'
            'Incorrect: ${item.incorrectCount}',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
      ),
    );
  }

  /// 🔹 X & Y Axis Titles
  FlTitlesData _titlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1),
      ),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30.h,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                data[index].difficultyLevel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
