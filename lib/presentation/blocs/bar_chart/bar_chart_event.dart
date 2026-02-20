part of 'bar_chart_bloc.dart';

@immutable
sealed class BarChartEvent {}

class FetchOptionMatrix extends BarChartEvent {
  final int testId;

  FetchOptionMatrix({required this.testId});
}
