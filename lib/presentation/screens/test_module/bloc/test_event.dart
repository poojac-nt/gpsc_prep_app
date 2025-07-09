import '../../../../domain/entities/question_language_model.dart';

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

class SubmitTest extends QuestionEvent {}

class ReviewTestEvent extends QuestionEvent {
  List<QuestionLanguageData> questions;
  List<String?> selectedOption;
  List<bool> answeredStatus;
  final List<String> questionType;

  ReviewTestEvent(
    this.questions,
    this.selectedOption,
    this.answeredStatus,
    this.questionType,
  );
}
