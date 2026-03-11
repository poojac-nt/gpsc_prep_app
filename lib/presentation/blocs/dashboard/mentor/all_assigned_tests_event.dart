part of 'all_assigned_tests_bloc.dart';

abstract class AllAssignedTestsEvent {
  const AllAssignedTestsEvent();
}

class FetchAllAssignedTests extends AllAssignedTestsEvent {}
