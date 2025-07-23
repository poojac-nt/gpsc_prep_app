part of 'question_preview_bloc.dart';

@immutable
sealed class QuestionPreviewEvent {}

class LoadQuestionsEvent extends QuestionPreviewEvent {
  final List<QuestionModel> questions;
  final String testName;

  LoadQuestionsEvent(this.questions, this.testName);
}

class ExportQuestionsToPdfEvent extends QuestionPreviewEvent {
  final String testName;
  final List<QuestionLanguageData> questions;

  ExportQuestionsToPdfEvent(this.questions, this.testName);
}
