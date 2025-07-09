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

  factory QuestionLanguageData.fromJson(Map<String, dynamic> json) {
    final data = _$QuestionLanguageDataFromJson(json);
    final correctKey = json['correct_answer'] as String?;
    // Step 2: Map "option_a" → actual string like "Delhi"
    final optionMap = {
      "option_a": data.optA,
      "option_b": data.optB,
      "option_c": data.optC,
      "option_d": data.optD,
    };

    final correctValue = optionMap[correctKey] ?? '';
    return QuestionLanguageData(
      optA: data.optA,
      optB: data.optB,
      optC: data.optC,
      optD: data.optD,
      explanation: data.explanation,
      questionTxt: data.questionTxt,
      correctAnswer: correctValue,
    );
  }

  Map<String, dynamic> toJson() => _$QuestionLanguageDataToJson(this);
  List<String> getOptions() {
    return [optA, optB, optC, optD];
  }
}
