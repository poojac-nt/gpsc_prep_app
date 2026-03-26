// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoursePayload _$CoursePayloadFromJson(Map<String, dynamic> json) =>
    CoursePayload(
      name: json['name'] as String,
      description: json['description'] as String?,
      testType: $enumDecode(_$CourseTestTypeEnumMap, json['test_type']),
      priceSingle: (json['single_assessment_price'] as num?)?.toInt(),
      priceDual: (json['dual_assessment_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CoursePayloadToJson(CoursePayload instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'single_assessment_price': instance.priceSingle,
      'dual_assessment_price': instance.priceDual,
      'test_type': _$CourseTestTypeEnumMap[instance.testType]!,
    };

const _$CourseTestTypeEnumMap = {
  CourseTestType.prelims: 'prelims',
  CourseTestType.mains: 'mains',
};
