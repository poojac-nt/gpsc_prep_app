import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class QuestionPieChart extends StatelessWidget {
  final int correct;
  final int incorrect;

  const QuestionPieChart({
    super.key,

    required this.correct,
    required this.incorrect,
  });

  @override
  Widget build(BuildContext context) {
    final total = correct + incorrect;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: correct.toDouble(),
            title: 'Correct\n${(correct / total * 100).toStringAsFixed(1)}%',
            color: Colors.green,
            radius: 70,
            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
          ),
          PieChartSectionData(
            value: incorrect.toDouble(),
            title:
                'Incorrect\n${(incorrect / total * 100).toStringAsFixed(1)}%',
            color: Colors.red,
            radius: 70,
            titleStyle: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
