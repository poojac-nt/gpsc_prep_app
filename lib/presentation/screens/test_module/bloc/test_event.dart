import '../../../../domain/entities/question_model.dart';

sealed class QuestionEvent {}

class LoadQuestion extends QuestionEvent {}

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

class ReviewTestMode extends QuestionEvent {
  List<Question> questions;
  List<String?> selectedOption;
  List<bool> answeredStatus;
  ReviewTestMode(this.questions, this.selectedOption, this.answeredStatus);
}
