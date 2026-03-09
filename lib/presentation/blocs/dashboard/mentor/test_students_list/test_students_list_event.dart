import 'package:equatable/equatable.dart';

abstract class TestStudentsListEvent extends Equatable {
  const TestStudentsListEvent();

  @override
  List<Object?> get props => [];
}

class FetchTestStudentsList extends TestStudentsListEvent {
  final int testId;

  const FetchTestStudentsList(this.testId);

  @override
  List<Object?> get props => [testId];
}
