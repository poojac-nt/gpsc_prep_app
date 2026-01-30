import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';

class DifficultyWiseBarChart extends StatelessWidget {
  final List<TestReviewByDifficulty> data;

  const DifficultyWiseBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxAttempted =
        data
            .map((e) => e.attemptedCount)
            .fold<int>(0, (a, b) => a > b ? a : b)
            .toDouble();

    // Determine adjustedMaxY based on max attempted
    double adjustedMaxY;
    if (maxAttempted <= 10) {
      adjustedMaxY = 10;
    } else {
      // Round up to nearest 50 as requested (e.g., 137 -> 150)
      adjustedMaxY = ((maxAttempted / 50).ceil() * 50).toDouble();
    }

    return SizedBox(
      height: 300.h,
      child: BarChart(
        BarChartData(
          maxY: adjustedMaxY,
          barTouchData: _barTouchData(),
          titlesData: _titlesData(adjustedMaxY),
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
            toY: item.attemptedCount.toDouble(),
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
  FlTitlesData _titlesData(double maxY) {
    // Calculate a "round" interval for better readability
    double interval;
    if (maxY <= 10) {
      interval = 2;
    } else if (maxY <= 25) {
      interval = 5;
    } else if (maxY <= 50) {
      interval = 10;
    } else if (maxY <= 100) {
      interval = 20;
    } else if (maxY <= 250) {
      interval = 50;
    } else {
      interval = (maxY / 5).ceilToDouble();
    }

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: interval,
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
