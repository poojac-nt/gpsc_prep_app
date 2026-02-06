import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';
import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:gpsc_prep_app/utils/enums/question_type_enum.dart';

class AnalyticsBarChart extends StatelessWidget {
  final List<TestReviewAnalytics> data;

  const AnalyticsBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Filter out categories with 0 attempts to keep labels clean
    final filteredData = data.where((e) => e.attemptedCount > 0).toList();
    final maxAttempted =
        filteredData
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
          barTouchData: _barTouchData(filteredData),
          titlesData: _titlesData(adjustedMaxY, filteredData),
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
          barGroups: _barGroups(filteredData),
        ),
      ),
    );
  }

  /// 🔹 Bars
  List<BarChartGroupData> _barGroups(List<TestReviewAnalytics> data) {
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
  BarTouchData _barTouchData(List<TestReviewAnalytics> data) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Colors.black87,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final item = data[group.x.toInt()];

          return BarTooltipItem(
            '${_getFullName(item.analyticsType).toUpperCase()}\n'
            'Correct: ${item.correctCount}\n'
            'Incorrect: ${item.incorrectCount}',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
      ),
    );
  }

  /// 🔹 X & Y Axis Titles
  FlTitlesData _titlesData(
    double maxY,
    List<TestReviewAnalytics> filteredData,
  ) {
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
          reservedSize: 60.h,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= filteredData.length) {
              return const SizedBox.shrink();
            }

            final rawLabel = filteredData[index].analyticsType;
            final fullName = _getFullName(rawLabel);

            final label = (fullName == rawLabel)
                ? _shortenName(rawLabel)
                : _capitalize(rawLabel);

            return SideTitleWidget(
              meta: meta,
              space: 10,
              angle: 0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp),
              ),
            );
          },
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _shortenName(String name) {
    if (name.isEmpty) return name;
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      if (words[0].length <= 4) return words[0];
      return "${words[0].substring(0, 3)}";
    } else {
      return words
          .map((w) {
            if (w.length <= 3) return w;
            return "${w.substring(0, 3)}";
          })
          .join(' ');
    }
  }

  String _getFullName(String type) {
    try {
      return DifficultyLevel.fromString(type).level;
    } catch (_) {
      try {
        return QuestionType.fromString(type).type;
      } catch (_) {
        return type; // Return original (e.g. subject name)
      }
    }
  }
}
