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
    );

Map<String, dynamic> _$TestModelToJson(TestModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'no_questions': instance.noQuestions,
      'test_type': _$TestTypeEnumMap[instance.testType]!,
      'total_marks': instance.totalMarks,
      'omr_link': instance.omrLink,
    };

const _$TestTypeEnumMap = {
  TestType.mcq: 'mcq',
  TestType.desc: 'desc',
  TestType.prelims: 'prelims',
};
