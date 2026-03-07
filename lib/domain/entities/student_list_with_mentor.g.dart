// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_list_with_mentor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentListWithMentor _$StudentListWithMentorFromJson(
        Map<String, dynamic> json) =>
    StudentListWithMentor(
      submissionId: (json['submission_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      studentName: json['student_name'] as String,
      submittedAt: json['submitted_at'] as String,
      mentors: (json['mentors'] as List<dynamic>)
          .map((e) => Mentor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentListWithMentorToJson(
        StudentListWithMentor instance) =>
    <String, dynamic>{
      'submission_id': instance.submissionId,
      'student_id': instance.studentId,
      'student_name': instance.studentName,
      'submitted_at': instance.submittedAt,
      'mentors': instance.mentors,
    };

Mentor _$MentorFromJson(Map<String, dynamic> json) => Mentor(
      mentorId: (json['mentor_id'] as num).toInt(),
      mentorName: json['mentor_name'] as String,
      subjectIds: (json['subject_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$MentorToJson(Mentor instance) => <String, dynamic>{
      'mentor_id': instance.mentorId,
      'mentor_name': instance.mentorName,
      'subject_ids': instance.subjectIds,
    };
