part of 'mentor_assignment_bloc.dart';

@immutable
sealed class MentorAssignmentEvent {}

class AssignMentorsToSubmissions extends MentorAssignmentEvent {
  final List<MentorAssignmentPayload> payloads;
  AssignMentorsToSubmissions(this.payloads);
}
