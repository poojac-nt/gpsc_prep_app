// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingSubmission _$PendingSubmissionFromJson(Map<String, dynamic> json) =>
    PendingSubmission(
      testId: (json['test_id'] as num).toInt(),
      testName: json['test_name'] as String,
      unassignedSubmissions: (json['unassigned_submissions'] as num).toInt(),
    );

Map<String, dynamic> _$PendingSubmissionToJson(PendingSubmission instance) =>
    <String, dynamic>{
      'test_id': instance.testId,
      'test_name': instance.testName,
      'unassigned_submissions': instance.unassignedSubmissions,
    };
