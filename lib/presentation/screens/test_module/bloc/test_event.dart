sealed class QuestionEvent {}

class LoadQuestion extends QuestionEvent {}

class AnswerQuestion extends QuestionEvent {
  final int index;
  AnswerQuestion(this.index);
}

class NextQuestion extends QuestionEvent {}

class PrevQuestion extends QuestionEvent {}

class JumpToQuestion extends QuestionEvent {
  final int index;
  JumpToQuestion(this.index);
}

class TimerTicked extends QuestionEvent {
  final int remainingSeconds;

  TimerTicked(this.remainingSeconds);
}

class SubmitTest extends QuestionEvent {}
