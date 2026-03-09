import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'all_assigned_tests_event.dart';
import 'all_assigned_tests_state.dart';

class AllAssignedTestsBloc
    extends Bloc<AllAssignedTestsEvent, AllAssignedTestsState> {
  final MentorRepository _mentorRepository;

  AllAssignedTestsBloc(this._mentorRepository)
    : super(AllAssignedTestsInitial()) {
    on<FetchAllAssignedTests>(_onFetchAllAssignedTests);
  }

  Future<void> _onFetchAllAssignedTests(
    FetchAllAssignedTests event,
    Emitter<AllAssignedTestsState> emit,
  ) async {
    emit(AllAssignedTestsLoading());
    try {
      final result = await _mentorRepository.fetchMentorSubmission();
      result.fold(
        (failure) => emit(AllAssignedTestsError(failure.message)),
        (data) => emit(AllAssignedTestsLoaded(data)),
      );
    } catch (e) {
      emit(AllAssignedTestsError(e.toString()));
    }
  }
}
