// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      tests: CourseTestsModel.fromJson(json['tests'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'tests': instance.tests,
    };

CourseTestsModel _$CourseTestsModelFromJson(Map<String, dynamic> json) =>
    CourseTestsModel(
      mcq: (json['mcq'] as List<dynamic>?)
          ?.map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      prelims: (json['prelims'] as List<dynamic>?)
          ?.map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      descriptive: (json['descriptive'] as List<dynamic>?)
          ?.map((e) => DescTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseTestsModelToJson(CourseTestsModel instance) =>
    <String, dynamic>{
      'mcq': instance.mcq,
      'prelims': instance.prelims,
      'descriptive': instance.descriptive,
    };
