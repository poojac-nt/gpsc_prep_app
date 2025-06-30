sealed class QuestionEvent {}

class LoadQuestion extends QuestionEvent {}

class AnswerQuestion extends QuestionEvent {}

class NextQuestion extends QuestionEvent {}

class PrevQuestion extends QuestionEvent {}

class JumpToQuestion extends QuestionEvent {
  final int index;
  JumpToQuestion(this.index);
}
