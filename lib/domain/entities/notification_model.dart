import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String? id;
  final String title;
  final String body;
  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;
  @JsonKey(name: 'is_sent')
  final bool? isSent;
  final String type; // 'course', 'test', 'general'
  @JsonKey(name: 'reference_id')
  final int? referenceId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.isSent = false,
    required this.type,
    this.referenceId,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? isSent,
    String? type,
    int? referenceId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isSent: isSent ?? this.isSent,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
