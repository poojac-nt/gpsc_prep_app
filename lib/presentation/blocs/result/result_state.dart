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
  final TestResultWithTopScoreModel result;
  final List<TestReviewAnalytics>? reviewByDifficulty;
  final List<TestReviewAnalytics>? reviewByQuestionType;

  ResultDataSuccess({
    required this.result,
    this.reviewByDifficulty,
    this.reviewByQuestionType,
  });
}

class SingleResultFailure extends ResultState {
  final Failure failure;

  SingleResultFailure(this.failure);
}
