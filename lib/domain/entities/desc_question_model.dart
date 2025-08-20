import 'package:gpsc_prep_app/domain/entities/desc_question_language_model.dart';
import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:json_annotation/json_annotation.dart';

part 'desc_question_model.g.dart';

@JsonSerializable()
class DescQuestionModel {
  @JsonKey(name: "id")
  final int id;

  @JsonKey(name: "question_type")
  final String questionType;

  @JsonKey(name: "difficulty_level")
  @DifficultyLevelConverter()
  final DifficultyLevel difficultyLevel;

  @JsonKey(name: "question_en")
  final DescQuestionLanguageData questionEn;

  @JsonKey(name: "question_hi")
  final DescQuestionLanguageData? questionHi;

  @JsonKey(name: "question_gj")
  final DescQuestionLanguageData? questionGj;

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

  DescQuestionModel({
    required this.id,
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

  factory DescQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$DescQuestionModelFromJson(json);
}

class DifficultyLevelConverter
    implements JsonConverter<DifficultyLevel, String> {
  const DifficultyLevelConverter();

  @override
  DifficultyLevel fromJson(String json) => DifficultyLevel.fromString(json);

  @override
  String toJson(DifficultyLevel level) => level.level;
}
