part of 'question_preview_bloc.dart';

@immutable
sealed class QuestionPreviewEvent {}

class ExportQuestionsToPdfEvent extends QuestionPreviewEvent {
  final String testName;
  final List<QuestionModel> questions;

  ExportQuestionsToPdfEvent(this.questions, this.testName);
}
