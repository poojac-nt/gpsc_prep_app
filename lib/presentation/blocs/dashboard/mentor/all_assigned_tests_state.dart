part of 'all_assigned_tests_bloc.dart';

abstract class AllAssignedTestsState {
  const AllAssignedTestsState();
}

class AllAssignedTestsInitial extends AllAssignedTestsState {}

class AllAssignedTestsLoading extends AllAssignedTestsState {}

class AllAssignedTestsLoaded extends AllAssignedTestsState {
  final List<MentorAssignmentListModel> data;

  const AllAssignedTestsLoaded(this.data);
}

class AllAssignedTestsError extends AllAssignedTestsState {
  final String message;

  const AllAssignedTestsError(this.message);
}
