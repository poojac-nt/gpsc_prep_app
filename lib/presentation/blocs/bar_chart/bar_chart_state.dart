import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import '../../../../../core/error/failure.dart';

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
