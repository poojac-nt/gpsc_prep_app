part of 'question_bloc.dart';

@immutable
sealed class QuestionEvent {}

class LoadQuestion extends QuestionEvent {
  final int testId;
  final String? language;

  LoadQuestion(this.testId, this.language);
}

class AnswerQuestion extends QuestionEvent {
  final String index;

  AnswerQuestion(this.index);
}

class NextQuestion extends QuestionEvent {}

class PrevQuestion extends QuestionEvent {}

class JumpToQuestion extends QuestionEvent {
  final int index;

  JumpToQuestion(this.index);
}

class ReviewTestEvent extends QuestionEvent {
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final List<bool?> isCorrect;

  ReviewTestEvent(
    this.questions,
    this.selectedOption,
    this.answeredStatus,
    this.isCorrect,
  );
}
