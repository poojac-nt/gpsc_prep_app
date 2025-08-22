part of 'question_bloc.dart';

@immutable
sealed class QuestionEvent {}

class LoadMcqQuestion extends QuestionEvent {
  final int testId;
  final String? language;

  LoadMcqQuestion(this.testId, this.language);
}

class LoadDescQuestion extends QuestionEvent {
  final int testId;
  final String? language;

  LoadDescQuestion(this.testId, this.language);
}

class ResetQuestionState extends QuestionEvent {}
