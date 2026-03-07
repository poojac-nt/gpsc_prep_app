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
}
