// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_test_submissions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorTestSubmissions _$MentorTestSubmissionsFromJson(
        Map<String, dynamic> json) =>
    MentorTestSubmissions(
      submissionId: (json['submission_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName: json['student_name'] as String,
      submittedAt: json['submitted_at'] as String,
      isChecked: json['is_checked'] as bool,
    );

Map<String, dynamic> _$MentorTestSubmissionsToJson(
        MentorTestSubmissions instance) =>
    <String, dynamic>{
      'submission_id': instance.submissionId,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'submitted_at': instance.submittedAt,
      'is_checked': instance.isChecked,
    };
