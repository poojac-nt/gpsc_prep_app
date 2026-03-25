// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_dashbord_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorDashboardData _$MentorDashboardDataFromJson(Map<String, dynamic> json) =>
    MentorDashboardData(
      latestAssignments: (json['latest_assignments'] as List<dynamic>)
          .map((e) => LatestAssignment.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAssigned: (json['total_assigned'] as num).toInt(),
      totalCompleted: (json['total_completed'] as num).toInt(),
    );

Map<String, dynamic> _$MentorDashboardDataToJson(
        MentorDashboardData instance) =>
    <String, dynamic>{
      'latest_assignments': instance.latestAssignments,
      'total_assigned': instance.totalAssigned,
      'total_completed': instance.totalCompleted,
    };

LatestAssignment _$LatestAssignmentFromJson(Map<String, dynamic> json) =>
    LatestAssignment(
      testId: (json['test_id'] as num).toInt(),
      testName: json['test_name'] as String,
      latestAssignedAt: DateTime.parse(json['latest_assigned_at'] as String),
      totalStudentsSubmissions:
          (json['total_students_submissions'] as num).toInt(),
      assignedNumberForThisMentor:
          (json['assigned_number_for_this_mentor'] as num).toInt(),
    );

Map<String, dynamic> _$LatestAssignmentToJson(LatestAssignment instance) =>
    <String, dynamic>{
      'test_id': instance.testId,
      'test_name': instance.testName,
      'latest_assigned_at': instance.latestAssignedAt.toIso8601String(),
      'total_students_submissions': instance.totalStudentsSubmissions,
      'assigned_number_for_this_mentor': instance.assignedNumberForThisMentor,
    };
