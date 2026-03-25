part of 'pie_chart_bloc.dart';

sealed class PieChartState {}

class PieChartInitial extends PieChartState {}

// A state to indicate that the performance data is being fetched.
class PerformanceSummaryLoading extends PieChartState {}

// A state that holds the data needed for the performance summary charts.
class PieChartResultSuccess extends PieChartState {
  final List<Map<String, dynamic>> correctnessCounts;
  final List<AttemptedQuestionStat> attemptedCounts;

  PieChartResultSuccess({
    required this.correctnessCounts,
    required this.attemptedCounts,
  });
}

// A state to represent a failure in fetching the data.
class PieChartResultFailure extends PieChartState {
  final Failure message;

  PieChartResultFailure(this.message);
}
