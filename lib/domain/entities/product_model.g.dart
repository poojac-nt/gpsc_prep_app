// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: (json['id'] as num).toInt(),
      productId: json['product_id'] as String,
      price: (json['price'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'price': instance.price,
      'title': instance.title,
      'description': instance.description,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
    };
