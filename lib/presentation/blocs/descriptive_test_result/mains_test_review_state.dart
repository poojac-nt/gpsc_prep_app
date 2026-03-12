part of 'mains_test_review_bloc.dart';

@immutable
abstract class MainsTestReviewState {}

class MainsTestReviewInitial extends MainsTestReviewState {}

class MainsTestReviewLoading extends MainsTestReviewState {}

class MainsTestReviewLoaded extends MainsTestReviewState {
  final MainsTestReviewModel result;
  MainsTestReviewLoaded(this.result);
}

class MainsTestReviewError extends MainsTestReviewState {
  final String message;
  MainsTestReviewError(this.message);
}
