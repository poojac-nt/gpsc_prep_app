import 'package:json_annotation/json_annotation.dart';

part 'desc_question_language_model.g.dart';

@JsonSerializable()
class DescQuestionLanguageData {
  @JsonKey(name: "question_txt")
  String questionTxt;
  @JsonKey(name: "answer_txt")
  String answerTxt;

  DescQuestionLanguageData({
    required this.questionTxt,
    required this.answerTxt,
  });

  factory DescQuestionLanguageData.fromJson(Map<String, dynamic> json) =>
      _$DescQuestionLanguageDataFromJson(json);
}
