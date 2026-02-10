import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'detailed_test_result_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class DetailedTestResult extends HiveObject {
  @HiveField(0)
  @JsonKey(name: "user_id")
  final int userId;

  @JsonKey(name: "test_id")
  @HiveField(1)
  final int testId;

  @JsonKey(name: "question_id")
  @HiveField(2)
  final int questionId;

  @JsonKey(name: "is_correct")
  @HiveField(3)
  final bool isCorrect;

  @JsonKey(name: "selected_option")
  @HiveField(4)
  final String? selectedOption;

  @JsonKey(name: "attempt_no")
  @HiveField(5)
  final int attemptNo;

  @JsonKey(name: "time_spent")
  @HiveField(6)
  final int timeSpent;

  DetailedTestResult({
    required this.userId,
    required this.testId,
    required this.questionId,
    required this.isCorrect,
    required this.selectedOption,
    required this.attemptNo,
    required this.timeSpent,
  });

  factory DetailedTestResult.fromJson(Map<String, dynamic> json) =>
      _$DetailedTestResultFromJson(json);

  Map<String, dynamic> toJson() => _$DetailedTestResultToJson(this);
}
