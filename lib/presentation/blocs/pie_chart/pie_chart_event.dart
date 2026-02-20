import 'package:flutter/cupertino.dart';

@immutable
sealed class PieChartEvent {}

class FetchPerformanceSummary extends PieChartEvent {
  final int testId;

  FetchPerformanceSummary({required this.testId});
}
