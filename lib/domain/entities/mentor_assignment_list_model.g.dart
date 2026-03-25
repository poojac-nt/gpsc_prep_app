// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_assignment_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorAssignmentListModel _$MentorAssignmentListModelFromJson(
        Map<String, dynamic> json) =>
    MentorAssignmentListModel(
      testId: (json['test_id'] as num).toInt(),
      testName: json['test_name'] as String,
      totalAssignedForTest: (json['total_assigned_for_test'] as num).toInt(),
      allCompleted: json['all_completed'] as bool,
      subjects: (json['subjects'] as List<dynamic>)
          .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MentorAssignmentListModelToJson(
        MentorAssignmentListModel instance) =>
    <String, dynamic>{
      'test_id': instance.testId,
      'test_name': instance.testName,
      'total_assigned_for_test': instance.totalAssignedForTest,
      'all_completed': instance.allCompleted,
      'subjects': instance.subjects,
    };
