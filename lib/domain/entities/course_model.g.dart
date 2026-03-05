// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      testType: json['test_type'] as String?,
      priceSingle: (json['single_assessment_price'] as num?)?.toInt(),
      priceDual: (json['dual_assessment_price'] as num?)?.toInt(),
      tests: json['tests'] == null
          ? null
          : CourseTestsModel.fromJson(json['tests'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'test_type': instance.testType,
      'single_assessment_price': instance.priceSingle,
      'dual_assessment_price': instance.priceDual,
      'tests': instance.tests,
    };

CourseTestsModel _$CourseTestsModelFromJson(Map<String, dynamic> json) =>
    CourseTestsModel(
      prelims: (json['prelims'] as List<dynamic>?)
          ?.map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      descriptive: (json['descriptive'] as List<dynamic>?)
          ?.map((e) => DescTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseTestsModelToJson(CourseTestsModel instance) =>
    <String, dynamic>{
      'prelims': instance.prelims,
      'descriptive': instance.descriptive,
    };
