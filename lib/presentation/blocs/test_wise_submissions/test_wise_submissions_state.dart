part of 'test_wise_submissions_bloc.dart';

@immutable
sealed class TestWiseSubmissionsState {}

final class TestWiseSubmissionsInitial extends TestWiseSubmissionsState {}

final class TestWiseSubmissionsLoading extends TestWiseSubmissionsState {}

final class TestWiseSubmissionsLoaded extends TestWiseSubmissionsState {
  final List<StudentListWithMentor> studentsWithMentors;
  final Set<int> selectedSubmissionIds;
  final String? errorMessage;

  TestWiseSubmissionsLoaded(
    this.studentsWithMentors, {
    this.selectedSubmissionIds = const {},
    this.errorMessage,
  });

  TestWiseSubmissionsLoaded copyWith({
    List<StudentListWithMentor>? studentsWithMentors,
    Set<int>? selectedSubmissionIds,
    String? errorMessage,
  }) {
    return TestWiseSubmissionsLoaded(
      studentsWithMentors ?? this.studentsWithMentors,
      selectedSubmissionIds:
          selectedSubmissionIds ?? this.selectedSubmissionIds,
      errorMessage: errorMessage,
    );
  }
}

final class TestWiseSubmissionsError extends TestWiseSubmissionsState {
  final String message;
  TestWiseSubmissionsError(this.message);
}
