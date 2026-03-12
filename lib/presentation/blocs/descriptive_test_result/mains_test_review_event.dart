part of 'mains_test_review_bloc.dart';

@immutable
abstract class MainsTestReviewEvent {}

class FetchMainsTestReview extends MainsTestReviewEvent {
  final int testId;
  FetchMainsTestReview(this.testId);
}
