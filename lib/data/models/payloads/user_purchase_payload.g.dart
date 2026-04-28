// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchase_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPurchasePayload _$UserPurchasePayloadFromJson(Map<String, dynamic> json) =>
    UserPurchasePayload(
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      testIds: (json['test_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      productId: json['product_id'] as String,
      purchaseToken: json['purchase_token'] as String,
      assessmentType:
          $enumDecodeNullable(_$AssessmentTypeEnumMap, json['assessment_type']),
    );

Map<String, dynamic> _$UserPurchasePayloadToJson(
        UserPurchasePayload instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'test_ids': instance.testIds,
      'product_id': instance.productId,
      'purchase_token': instance.purchaseToken,
      'assessment_type': _$AssessmentTypeEnumMap[instance.assessmentType],
    };

const _$AssessmentTypeEnumMap = {
  AssessmentType.single: 'single',
  AssessmentType.double: 'double',
};
