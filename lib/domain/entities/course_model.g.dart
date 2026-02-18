// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: (json['course_id'] as num).toInt(),
      name: json['course_name'] as String,
      description: json['course_description'] as String,
      courseTests: (json['tests'] as List<dynamic>)
          .map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'course_id': instance.id,
      'course_name': instance.name,
      'course_description': instance.description,
      'tests': instance.courseTests,
    };
