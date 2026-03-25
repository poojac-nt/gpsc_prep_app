// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_wise_pending_submissions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestWisePendingSubmission _$TestWisePendingSubmissionFromJson(
        Map<String, dynamic> json) =>
    TestWisePendingSubmission(
      submissionId: (json['submission_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName: json['student_name'] as String,
      submittedAt: json['submitted_at'] as String,
    );

Map<String, dynamic> _$TestWisePendingSubmissionToJson(
        TestWisePendingSubmission instance) =>
    <String, dynamic>{
      'submission_id': instance.submissionId,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'submitted_at': instance.submittedAt,
    };
