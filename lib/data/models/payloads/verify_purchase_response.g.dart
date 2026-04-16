// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_purchase_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyPurchaseResponse _$VerifyPurchaseResponseFromJson(
        Map<String, dynamic> json) =>
    VerifyPurchaseResponse(
      isValid: json['is_valid'] as bool,
      courseId: (json['course_id'] as num).toInt(),
      testIds:
          (json['test_ids'] as List<dynamic>).map((e) => e as String).toList(),
      assessmentType:
          $enumDecode(_$AssessmentTypeEnumMap, json['assessment_type']),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$VerifyPurchaseResponseToJson(
        VerifyPurchaseResponse instance) =>
    <String, dynamic>{
      'is_valid': instance.isValid,
      'course_id': instance.courseId,
      'test_ids': instance.testIds,
      'assessment_type': _$AssessmentTypeEnumMap[instance.assessmentType]!,
      'is_active': instance.isActive,
    };

const _$AssessmentTypeEnumMap = {
  AssessmentType.single: 'single',
  AssessmentType.double: 'double',
};
