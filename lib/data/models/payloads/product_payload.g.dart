// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPayload _$ProductPayloadFromJson(Map<String, dynamic> json) =>
    ProductPayload(
      title: json['title'] as String,
      productId: json['product_id'] as String,
      price: (json['price'] as num).toInt(),
      description: json['description'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$ProductPayloadToJson(ProductPayload instance) =>
    <String, dynamic>{
      'title': instance.title,
      'product_id': instance.productId,
      'price': instance.price,
      'description': instance.description,
      'is_active': instance.isActive,
    };
