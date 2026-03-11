part of 'test_wise_submissions_bloc.dart';

@immutable
sealed class TestWiseSubmissionsEvent {}

class FetchTestWisePendingSubmissions extends TestWiseSubmissionsEvent {
  final int testId;
  FetchTestWisePendingSubmissions(this.testId);
}

class ToggleSubmissionSelection extends TestWiseSubmissionsEvent {
  final StudentListWithMentor submission;
  ToggleSubmissionSelection(this.submission);
}

class ClearSubmissionSelection extends TestWiseSubmissionsEvent {}
