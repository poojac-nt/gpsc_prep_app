// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPurchaseModel _$UserPurchaseModelFromJson(Map<String, dynamic> json) =>
    UserPurchaseModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      testIds: json['test_ids'] as String,
      assessmentType:
          $enumDecode(_$AssessmentTypeEnumMap, json['assessment_type']),
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$UserPurchaseModelToJson(UserPurchaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'test_ids': instance.testIds,
      'assessment_type': _$AssessmentTypeEnumMap[instance.assessmentType]!,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
    };

const _$AssessmentTypeEnumMap = {
  AssessmentType.single: 'single',
  AssessmentType.double: 'double',
};
