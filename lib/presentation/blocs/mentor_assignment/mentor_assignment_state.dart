part of 'mentor_assignment_bloc.dart';

@immutable
sealed class MentorAssignmentState {}

final class MentorAssignmentInitial extends MentorAssignmentState {}

final class MentorAssignmentLoading extends MentorAssignmentState {}

final class MentorsAssignedSuccessfully extends MentorAssignmentState {}

final class MentorAssignmentError extends MentorAssignmentState {
  final String message;
  MentorAssignmentError(this.message);
}
