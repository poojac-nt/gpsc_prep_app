import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int? id;
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
  @JsonKey(name: 'test_type')
  final String? testType;
  @JsonKey(name: 'target_audience')
  final String targetAudience; // 'all', 'student', 'mentor'

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.isSent = false,
    required this.type,
    this.referenceId,
    this.createdAt,
    this.testType,
    this.targetAudience = 'all',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? scheduledAt,
    bool? isSent,
    String? type,
    int? referenceId,
    DateTime? createdAt,
    String? testType,
    String? targetAudience,
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
      testType: testType ?? this.testType,
      targetAudience: targetAudience ?? this.targetAudience,
    );
  }
}
