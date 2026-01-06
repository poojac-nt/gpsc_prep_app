part of 'bar_chart_bloc.dart';

@immutable
sealed class BarChartState {}

class BarChartInitial extends BarChartState {}

class OptionMatrixLoading extends BarChartState {}

class OptionMatrixSuccess extends BarChartState {
  final List<OptionMatrixModel> questionStats;

  OptionMatrixSuccess(this.questionStats);
}

class OptionMatrixResultFailure extends BarChartState {
  final Failure failure;

  OptionMatrixResultFailure(this.failure);
}
