import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

extension QuestionModelExtension on QuestionModel {
  QuestionLanguageData getLanguageData(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return questionHi ?? questionEn;
      case 'gj':
        return questionGj ?? questionEn;
      case 'en':
      default:
        return questionEn;
    }
  }
}
