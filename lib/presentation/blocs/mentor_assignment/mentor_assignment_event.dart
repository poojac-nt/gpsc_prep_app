import 'package:flutter/foundation.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';

@immutable
sealed class MentorAssignmentEvent {}

class AssignMentorsToSubmissions extends MentorAssignmentEvent {
  final List<MentorAssignmentPayload> payloads;
  AssignMentorsToSubmissions(this.payloads);
}
