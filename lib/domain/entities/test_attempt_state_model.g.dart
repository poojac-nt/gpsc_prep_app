// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_attempt_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestAttemptState _$TestAttemptStateFromJson(Map<String, dynamic> json) =>
    TestAttemptState(
      attemptsDone: (json['attempts_done'] as num).toInt(),
      maxAttempts: (json['max_attempts'] as num).toInt(),
      nextAttemptNo: (json['next_attempt_no'] as num).toInt(),
      cooldownHours: (json['cooldown_hours'] as num).toInt(),
      canRetry: json['can_retry'] as bool,
      retryAvailableAt: json['retry_available_at'] as String?,
      lastAttemptAt: json['last_attempt_at'] as String?,
    );

Map<String, dynamic> _$TestAttemptStateToJson(TestAttemptState instance) =>
    <String, dynamic>{
      'attempts_done': instance.attemptsDone,
      'max_attempts': instance.maxAttempts,
      'next_attempt_no': instance.nextAttemptNo,
      'cooldown_hours': instance.cooldownHours,
      'can_retry': instance.canRetry,
      'retry_available_at': instance.retryAvailableAt,
      'last_attempt_at': instance.lastAttemptAt,
    };
