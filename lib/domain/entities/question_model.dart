import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  @JsonKey(name: "question_type")
  final String questionType;

  @JsonKey(name: "difficulty_level")
  @DifficultyLevelConverter()
  final DifficultyLevel difficultyLevel;

  @JsonKey(name: "question_en")
  final QuestionLanguageData questionEn;

  @JsonKey(name: "question_hi")
  final QuestionLanguageData? questionHi;

  @JsonKey(name: "question_gj")
  final QuestionLanguageData? questionGj;

  @JsonKey(name: "created_at")
  final String createdAt;

  @JsonKey(name: "marks")
  final int marks;

  @JsonKey(name: "question_hash")
  final String questionHash;

  @JsonKey(name: "subject_name")
  final String subjectName;

  @JsonKey(name: "topic_name")
  final String topicName;

  QuestionModel({
    required this.questionType,
    required this.difficultyLevel,
    required this.questionEn,
    required this.questionHi,
    required this.questionGj,
    required this.createdAt,
    required this.marks,
    required this.questionHash,
    required this.subjectName,
    required this.topicName,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}

class DifficultyLevelConverter
    implements JsonConverter<DifficultyLevel, String> {
  const DifficultyLevelConverter();

  @override
  DifficultyLevel fromJson(String json) => DifficultyLevel.fromString(json);

  @override
  String toJson(DifficultyLevel level) => level.level;
}
