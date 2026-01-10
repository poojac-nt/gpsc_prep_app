import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';

class McqVerticalBarChart extends StatelessWidget {
  final int questionId;
  final List<OptionMatrixModel> optionStats;

  const McqVerticalBarChart({
    super.key,
    required this.questionId,
    required this.optionStats,
  });

  @override
  Widget build(BuildContext context) {
    final filteredStats =
        optionStats.where((e) => e.questionId == questionId).toList();

    return _BarChartView(optionStats: filteredStats);
  }
}

class _BarChartView extends StatelessWidget {
  final List<OptionMatrixModel> optionStats;

  const _BarChartView({required this.optionStats});

  static const List<String> _options = ['A', 'B', 'C', 'D'];

  // Material 3 color palette for each option
  static const List<Color> _optionColors = [
    Color(0xFF6750A4), // Purple - Primary
    Colors.teal, // Teal - Secondary
    Color(0xFFB3261E), // Red - Error
    Color(0xFF006A60), // Green - Tertiary
  ];

  Map<String, int> _buildOptionCounts() {
    final Map<String, int> counts = {'A': 0, 'B': 0, 'C': 0, 'D': 0};

    for (final stat in optionStats) {
      final optionKey = _extractOptionKey(stat.selectedOption);
      if (counts.containsKey(optionKey)) {
        counts[optionKey] = stat.totalUsers;
      }
    }

    return counts;
  }

  String _extractOptionKey(String rawOption) {
    final match = RegExp(
      r'^\(?\s*([a-eA-E])\s*\)',
      caseSensitive: false,
    ).firstMatch(rawOption.trim());

    return match?.group(1)?.toUpperCase() ?? '';
  }

  int _totalAttempts(Map<String, int> counts) {
    return counts.values.fold(0, (sum, v) => sum + v);
  }

  double _percentage(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final optionCounts = _buildOptionCounts();
    final totalAttempts = _totalAttempts(optionCounts);
    final colorScheme = Theme.of(context).colorScheme;

    return TestModule(
      title: "Option Selection Breakdown",
      cards: [
        Container(
          height: 300.h,
          width: double.maxFinite,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BarChart(
            BarChartData(
              maxY: totalAttempts.toDouble(),
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withAlpha(51),
                    width: 1,
                  ),
                ),
              ),
              barTouchData: _barTouchData(
                optionCounts,
                totalAttempts,
                colorScheme,
              ),
              titlesData: _titlesData(colorScheme),
              barGroups: _buildBarGroups(
                optionCounts,
                totalAttempts,
                colorScheme,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarTouchData _barTouchData(
    Map<String, int> optionCounts,
    int totalAttempts,
    ColorScheme colorScheme,
  ) {
    return BarTouchData(
      enabled: true,
      handleBuiltInTouches: false,
      touchTooltipData: BarTouchTooltipData(
        tooltipMargin: 0,
        getTooltipColor: (group) => Colors.transparent,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final option = _options[group.x.toInt()];
          final count = optionCounts[option]!;
          final percent = _percentage(count, totalAttempts);
          if (count == 0) return null;
          return BarTooltipItem(
            '${percent.toStringAsFixed(0)}%',
            TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _titlesData(ColorScheme colorScheme) {
    return FlTitlesData(
      leftTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      topTitles: const AxisTitles(),

      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          reservedSize: 25.h,
          showTitles: true,
          getTitlesWidget: (value, _) {
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                _options[value.toInt()],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    Map<String, int> optionCounts,
    int totalAttempts,
    ColorScheme colorScheme,
  ) {
    return List.generate(_options.length, (index) {
      final option = _options[index];
      final count = optionCounts[option]!;
      final barColor = _optionColors[index];

      // Darker grey for bars with no data, original light implementation otherwise
      final backDrawColor =
          count == 0
              ? colorScheme
                  .outlineVariant // Darker grey
              : colorScheme.surfaceContainerHighest.withAlpha(40);

      return BarChartGroupData(
        x: index,
        showingTooltipIndicators: count > 0 ? [0] : [],
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            width: 32.w,
            borderRadius: BorderRadius.circular(8.r),
            gradient:
                count == 0
                    ? null
                    : LinearGradient(
                      colors: [barColor, barColor.withAlpha(80)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            color: count == 0 ? Colors.transparent : null,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: totalAttempts.toDouble(),
              color: backDrawColor,
            ),
          ),
        ],
      );
    });
  }
}
