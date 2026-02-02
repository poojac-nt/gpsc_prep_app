import 'package:json_annotation/json_annotation.dart';

part 'test_attempt_state_model.g.dart';

@JsonSerializable()
class TestAttemptState {
  @JsonKey(name: "attempts_done")
  int attemptsDone;
  @JsonKey(name: "max_attempts")
  int maxAttempts;
  @JsonKey(name: "next_attempt_no")
  int nextAttemptNo;
  @JsonKey(name: "cooldown_hours")
  int cooldownHours;
  @JsonKey(name: "can_retry")
  bool canRetry;
  @JsonKey(name: "retry_available_at")
  String? retryAvailableAt;

  TestAttemptState({
    required this.attemptsDone,
    required this.maxAttempts,
    required this.nextAttemptNo,
    required this.cooldownHours,
    required this.canRetry,
    this.retryAvailableAt,
  });

  factory TestAttemptState.fromJson(Map<String, dynamic> json) =>
      _$TestAttemptStateFromJson(json);

  Map<String, dynamic> toJson() => _$TestAttemptStateToJson(this);
}
