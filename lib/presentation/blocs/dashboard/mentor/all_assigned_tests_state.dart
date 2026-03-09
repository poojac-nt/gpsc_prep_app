import 'package:gpsc_prep_app/domain/entities/mentor_assignment_list_model.dart';

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
