import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'test_wise_submissions_event.dart';
import 'test_wise_submissions_state.dart';

class TestWiseSubmissionsBloc
    extends Bloc<TestWiseSubmissionsEvent, TestWiseSubmissionsState> {
  final MentorRepository _repository;

  TestWiseSubmissionsBloc(this._repository)
    : super(TestWiseSubmissionsInitial()) {
    on<FetchTestWisePendingSubmissions>(_onFetchTestWisePendingSubmissions);
    on<ToggleSubmissionSelection>(_onToggleSubmissionSelection);
    on<ClearSubmissionSelection>(_onClearSubmissionSelection);
  }

  Future<void> _onFetchTestWisePendingSubmissions(
    FetchTestWisePendingSubmissions event,
    Emitter<TestWiseSubmissionsState> emit,
  ) async {
    emit(TestWiseSubmissionsLoading());
    final result = await _repository.fetchTestWisePendingSubmission(
      testId: event.testId,
    );
    result.fold(
      (failure) => emit(TestWiseSubmissionsError(failure.message)),
      (submissions) => emit(TestWiseSubmissionsLoaded(submissions)),
    );
  }

  void _onToggleSubmissionSelection(
    ToggleSubmissionSelection event,
    Emitter<TestWiseSubmissionsState> emit,
  ) {
    if (state is TestWiseSubmissionsLoaded) {
      final currentState = state as TestWiseSubmissionsLoaded;
      final selectedIds = Set<int>.from(currentState.selectedSubmissionIds);
      final submissionId = event.submission.submissionId;

      if (selectedIds.contains(submissionId)) {
        selectedIds.remove(submissionId);
        emit(currentState.copyWith(selectedSubmissionIds: selectedIds));
      } else {
        if (selectedIds.isNotEmpty) {
          final firstSelectedId = selectedIds.first;
          final firstSelectedSub = currentState.studentsWithMentors.firstWhere(
            (s) => s.submissionId == firstSelectedId,
          );

          if (firstSelectedSub.assessmentType !=
              event.submission.assessmentType) {
            emit(
              currentState.copyWith(
                errorMessage:
                    "Please select tests of the same assessment type for bulk assignment.",
              ),
            );
            return;
          }
        }
        selectedIds.add(submissionId);
        emit(currentState.copyWith(selectedSubmissionIds: selectedIds));
      }
    }
  }

  void _onClearSubmissionSelection(
    ClearSubmissionSelection event,
    Emitter<TestWiseSubmissionsState> emit,
  ) {
    if (state is TestWiseSubmissionsLoaded) {
      final currentState = state as TestWiseSubmissionsLoaded;
      emit(currentState.copyWith(selectedSubmissionIds: {}));
    }
  }
}
