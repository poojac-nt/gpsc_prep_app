// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoursePayload _$CoursePayloadFromJson(Map<String, dynamic> json) =>
    CoursePayload(
      name: json['name'] as String,
      description: json['description'] as String?,
      testType: json['test_type'] as String,
    );

Map<String, dynamic> _$CoursePayloadToJson(CoursePayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'test_type': instance.testType,
    };
