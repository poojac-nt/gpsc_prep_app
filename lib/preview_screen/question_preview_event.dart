part of 'question_preview_bloc.dart';

@immutable
sealed class QuestionPreviewEvent {}

class LoadQuestionsEvent extends QuestionPreviewEvent {
  final List<QuestionModel> questions;

  LoadQuestionsEvent(this.questions);
}

class ExportQuestionsToPdfEvent extends QuestionPreviewEvent {
  final List<QuestionLanguageData> questions;

  ExportQuestionsToPdfEvent(this.questions);
}
