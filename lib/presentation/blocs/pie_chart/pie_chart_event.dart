part of 'pie_chart_bloc.dart';

sealed class PieChartEvent {}

class FetchPerformanceSummary extends PieChartEvent {
  final int testId;

  FetchPerformanceSummary({required this.testId});
}
