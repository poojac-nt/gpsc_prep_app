// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_assign_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorAssignmentPayload _$MentorAssignmentPayloadFromJson(
        Map<String, dynamic> json) =>
    MentorAssignmentPayload(
      submissionId: (json['submission_id'] as num).toInt(),
      mentorId: (json['mentor_id'] as num).toInt(),
      assignedBy: (json['assigned_by'] as num).toInt(),
    );

Map<String, dynamic> _$MentorAssignmentPayloadToJson(
        MentorAssignmentPayload instance) =>
    <String, dynamic>{
      'submission_id': instance.submissionId,
      'mentor_id': instance.mentorId,
      'assigned_by': instance.assignedBy,
    };
