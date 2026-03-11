abstract class TestStudentsListEvent {
  const TestStudentsListEvent();
}

class FetchTestStudentsList extends TestStudentsListEvent {
  final int testId;

  const FetchTestStudentsList(this.testId);
}
