import 'package:json_annotation/json_annotation.dart';

part 'question_language_model.g.dart';

@JsonSerializable()
class QuestionLanguageData {
  @JsonKey(name: "opt_a")
  String optA;
  @JsonKey(name: "opt_b")
  String optB;
  @JsonKey(name: "opt_c")
  String optC;
  @JsonKey(name: "opt_d")
  String optD;
  @JsonKey(name: "explanation")
  String explanation;
  @JsonKey(name: "question_txt")
  String questionTxt;
  @JsonKey(name: "correct_answer")
  String correctAnswer;

  QuestionLanguageData({
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.explanation,
    required this.questionTxt,
    required this.correctAnswer,
  });

  factory QuestionLanguageData.fromJson(Map<String, dynamic> json) =>
      _$QuestionLanguageDataFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionLanguageDataToJson(this);
  List<String> getOptions() {
    return [optA, optB, optC, optD];
  }
}
