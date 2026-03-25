part of 'test_students_list_bloc.dart';

abstract class TestStudentsListState {
  const TestStudentsListState();
}

class TestStudentsListInitial extends TestStudentsListState {}

class TestStudentsListLoading extends TestStudentsListState {}

class TestStudentsListLoaded extends TestStudentsListState {
  final List<MentorTestSubmissions> submissions;

  const TestStudentsListLoaded(this.submissions);
}

class TestStudentsListError extends TestStudentsListState {
  final String message;

  const TestStudentsListError(this.message);
}
