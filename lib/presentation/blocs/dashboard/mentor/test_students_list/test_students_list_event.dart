part of 'test_students_list_bloc.dart';

abstract class TestStudentsListEvent {
  const TestStudentsListEvent();
}

class FetchTestStudentsList extends TestStudentsListEvent {
  final int testId;

  const FetchTestStudentsList(this.testId);
}
