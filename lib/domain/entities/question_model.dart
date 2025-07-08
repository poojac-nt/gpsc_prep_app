import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  final String questionType;
  final String difficultyLevel;
  final String topicName;
  final Map<String, QuestionLanguageData> languages;
  QuestionModel({
    required this.questionType,
    required this.difficultyLevel,
    required this.topicName,
    required this.languages,
  });
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, QuestionLanguageData> langMap = {};
    if (json['languages'] != null) {
      (json['languages'] as Map<String, dynamic>).forEach((key, value) {
        langMap[key] = QuestionLanguageData.fromJson(value);
      });
    }
    return QuestionModel(
      questionType: json['question_type'],
      difficultyLevel: json['difficulty_level'],
      topicName: json['topic_name'],
      languages: langMap,
    );
  }
  Map<String, dynamic> toJson() => {
    'question_type': questionType,
    'difficulty_level': difficultyLevel,
    'topic_name': topicName,
    'languages': languages.map((key, value) => MapEntry(key, value.toJson())),
  };
}
