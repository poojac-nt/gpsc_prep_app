// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchase_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPurchasePayload _$UserPurchasePayloadFromJson(Map<String, dynamic> json) =>
    UserPurchasePayload(
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      assessmentType:
          $enumDecode(_$AssessmentTypeEnumMap, json['assessment_type']),
    );

Map<String, dynamic> _$UserPurchasePayloadToJson(
        UserPurchasePayload instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'assessment_type': _$AssessmentTypeEnumMap[instance.assessmentType]!,
    };

const _$AssessmentTypeEnumMap = {
  AssessmentType.single: 'single',
  AssessmentType.double: 'double',
};
