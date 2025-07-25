part of 'question_preview_bloc.dart';

@immutable
sealed class QuestionPreviewState {}

final class QuestionPreviewInitial extends QuestionPreviewState {}

class QuestionPreviewLoaded extends QuestionPreviewState {
  final String testName;
  final List<QuestionLanguageData> questions;

  QuestionPreviewLoaded(this.questions, {this.testName = "Test"});
}

class QuestionExporting extends QuestionPreviewState {}

class QuestionExported extends QuestionPreviewState {
  final List<QuestionLanguageData> questions;
  final String filePath;
  final String testName;

  QuestionExported({
    required this.questions,
    required this.filePath,
    required this.testName,
  });
}

class QuestionPreviewError extends QuestionPreviewState {
  final String message;

  QuestionPreviewError(this.message);
}
