// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) =>
    AdminStatsModel(
      totalMentors: (json['total_mentors'] as num).toInt(),
      totalCourses: (json['total_courses'] as num).toInt(),
    );

Map<String, dynamic> _$AdminStatsModelToJson(AdminStatsModel instance) =>
    <String, dynamic>{
      'total_mentors': instance.totalMentors,
      'total_courses': instance.totalCourses,
    };
