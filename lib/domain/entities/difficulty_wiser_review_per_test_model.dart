import 'package:json_annotation/json_annotation.dart';

part 'difficulty_wiser_review_per_test_model.g.dart';

@JsonSerializable()
class DifficultWiseReviewPerTestModel {
  @JsonKey(name: "difficulty_level")
  String difficultyLevel;
  @JsonKey(name: "total_questions_in_test")
  int totalQuestionsInTest;
  @JsonKey(name: "attempted_count")
  int attemptedCount;
  @JsonKey(name: "correct_count")
  int correctCount;
  @JsonKey(name: "incorrect_count")
  int incorrectCount;

  DifficultWiseReviewPerTestModel({
    required this.difficultyLevel,
    required this.totalQuestionsInTest,
    required this.attemptedCount,
    required this.correctCount,
    required this.incorrectCount,
  });

  factory DifficultWiseReviewPerTestModel.fromJson(Map<String, dynamic> json) =>
      _$DifficultWiseReviewPerTestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DifficultWiseReviewPerTestModelToJson(this);
}
