// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_purchase_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPurchasePayload _$UserPurchasePayloadFromJson(Map<String, dynamic> json) =>
    UserPurchasePayload(
      userId: (json['user_id'] as num).toInt(),
      courseId: (json['course_id'] as num).toInt(),
      productId: json['product_id'] as String,
      purchaseToken: json['purchase_token'] as String,
    );

Map<String, dynamic> _$UserPurchasePayloadToJson(
        UserPurchasePayload instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'product_id': instance.productId,
      'purchase_token': instance.purchaseToken,
    };
