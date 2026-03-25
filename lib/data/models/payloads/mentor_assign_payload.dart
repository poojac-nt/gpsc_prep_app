import 'package:json_annotation/json_annotation.dart';

part 'mentor_assign_payload.g.dart';

@JsonSerializable()
class MentorAssignmentPayload {
  @JsonKey(name: "submission_id")
  int submissionId;
  @JsonKey(name: "mentor_id")
  int mentorId;
  @JsonKey(name: "assigned_by")
  int assignedBy;

  MentorAssignmentPayload({
    required this.submissionId,
    required this.mentorId,
    required this.assignedBy,
  });

  factory MentorAssignmentPayload.fromJson(Map<String, dynamic> json) =>
      _$MentorAssignmentPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$MentorAssignmentPayloadToJson(this);
}
