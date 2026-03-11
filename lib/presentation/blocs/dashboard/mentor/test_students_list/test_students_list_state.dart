import 'package:gpsc_prep_app/domain/entities/mentor_test_submissions.dart';

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
