part of 'result_bloc.dart';

@immutable
sealed class ResultState {}

class ResultStateInitial extends ResultState {}

class ResultLoading extends ResultState {}

class ResultError extends ResultState {
  final Failure message;

  ResultError({required this.message});
}

class ResultDataSuccess extends ResultState {
  final TestResultWithTopScoreModel? result;

  ResultDataSuccess({this.result});
}

class SingleResultFailure extends ResultState {
  final Failure failure;

  SingleResultFailure(this.failure);
}
