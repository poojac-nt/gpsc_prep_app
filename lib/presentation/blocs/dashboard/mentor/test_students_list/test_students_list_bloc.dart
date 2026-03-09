import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'test_students_list_event.dart';
import 'test_students_list_state.dart';

class TestStudentsListBloc
    extends Bloc<TestStudentsListEvent, TestStudentsListState> {
  final MentorRepository _mentorRepository;

  TestStudentsListBloc(this._mentorRepository)
    : super(TestStudentsListInitial()) {
    on<FetchTestStudentsList>(_onFetchTestStudentsList);
  }

  Future<void> _onFetchTestStudentsList(
    FetchTestStudentsList event,
    Emitter<TestStudentsListState> emit,
  ) async {
    emit(TestStudentsListLoading());
    final result = await _mentorRepository.fetchMentorTestSubmission(
      testId: event.testId,
    );
    result.fold(
      (failure) => emit(TestStudentsListError(failure.message)),
      (submissions) => emit(TestStudentsListLoaded(submissions)),
    );
  }
}
