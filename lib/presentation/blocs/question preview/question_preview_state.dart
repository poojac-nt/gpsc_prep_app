part of 'question_preview_bloc.dart';

@immutable
sealed class QuestionPreviewState {}

final class QuestionPreviewInitial extends QuestionPreviewState {}

class QuestionExporting extends QuestionPreviewState {}

class QuestionExported extends QuestionPreviewState {
  final String filePath;

  QuestionExported({required this.filePath});
}

class QuestionExportError extends QuestionPreviewState {
  final Failure failure;

  QuestionExportError(this.failure);
}
