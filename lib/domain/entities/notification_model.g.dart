// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      isSent: json['is_sent'] as bool? ?? false,
      type: json['type'] as String,
      referenceId: (json['reference_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'is_sent': instance.isSent,
      'type': instance.type,
      'reference_id': instance.referenceId,
      'created_at': instance.createdAt?.toIso8601String(),
    };
