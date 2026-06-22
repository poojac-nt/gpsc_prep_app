// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestModel _$TestModelFromJson(Map<String, dynamic> json) => TestModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
      noQuestions: (json['no_questions'] as num).toInt(),
      testType: $enumDecode(_$TestTypeEnumMap, json['test_type']),
      totalMarks: (json['total_marks'] as num).toInt(),
      omrLink: json['omr_link'] as String?,
      availableAt: json['available_at'] == null
          ? null
          : DateTime.parse(json['available_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      totalAttempt: (json['total_attempts'] as num?)?.toInt(),
      singleProduct: json['single_assessment_price'] == null
          ? null
          : ProductModel.fromJson(
              json['single_assessment_price'] as Map<String, dynamic>),
      dualProduct: json['double_assessment_price'] == null
          ? null
          : ProductModel.fromJson(
              json['double_assessment_price'] as Map<String, dynamic>),
      allowedLanguages: (json['allowed_languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TestModelToJson(TestModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'no_questions': instance.noQuestions,
      'test_type': _$TestTypeEnumMap[instance.testType]!,
      'total_marks': instance.totalMarks,
      'omr_link': instance.omrLink,
      'available_at': instance.availableAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'total_attempts': instance.totalAttempt,
      'single_assessment_price': instance.singleProduct,
      'double_assessment_price': instance.dualProduct,
      'allowed_languages': instance.allowedLanguages,
    };

const _$TestTypeEnumMap = {
  TestType.mcq: 'mcq',
  TestType.desc: 'desc',
  TestType.prelims: 'prelims',
  TestType.mains: 'mains',
};
