import 'package:json_annotation/json_annotation.dart';

part 'desc_answer_model.g.dart';

@JsonSerializable()
class DescAnswerModel {
  @JsonKey(name: "user_id")
  final int userId;

  @JsonKey(name: "test_id")
  final int testId;

  @JsonKey(name: "question_id")
  final int questionId;

  /// The answer stored as string (could be typed text or a link)
  @JsonKey(name: "answer")
  final dynamic answer;

  DescAnswerModel({
    required this.userId,
    required this.testId,
    required this.questionId,
    required this.answer,
  });

  factory DescAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$DescAnswerModelFromJson(json);

  Map<String, dynamic> toJson() => _$DescAnswerModelToJson(this);
}
