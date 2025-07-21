import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  @JsonKey(name: "question_type")
  String questionType;
  @JsonKey(name: "difficulty_level")
  String difficultyLevel;
  @JsonKey(name: "question_en")
  QuestionLanguageData questionEn;
  @JsonKey(name: "question_hi")
  QuestionLanguageData? questionHi;
  @JsonKey(name: "question_gj")
  QuestionLanguageData? questionGj;
  @JsonKey(name: "created_at")
  String createdAt;
  @JsonKey(name: "marks")
  int marks;
  @JsonKey(name: "question_hash")
  String questionHash;

  QuestionModel({
    required this.questionType,
    required this.difficultyLevel,
    required this.questionEn,
    required this.questionHi,
    required this.questionGj,
    required this.createdAt,
    required this.marks,
    required this.questionHash,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}
