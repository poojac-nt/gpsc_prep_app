import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';

import '../../../../domain/entities/question_model.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  QuestionBloc() : super(QuestionInitial()) {
    on<LoadQuestion>(_loadQuestion);
    on<TimerTicked>(_onTimerTicked);
    on<SubmitTest>(_onSubmit);
    on<ReviewTestMode>(_onReviewTest);
    on<AnswerQuestion>(_answerQuestion);
    on<NextQuestion>(_nextQuestion);
    on<PrevQuestion>(_prevQuestion);
    on<JumpToQuestion>(_jumpToQuestion);
  }

  Timer? timer;

  Future<void> _loadQuestion(
    LoadQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    List<Question> questions = Question.sampleQuestion();

    timer?.cancel();
    int tickCount = 30 * 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      tickCount--;
      add(TimerTicked(tickCount));

      if (tickCount <= 0) {
        timer.cancel();
      }
    });
    emit(
      QuestionLoaded(
        questions: questions,
        currentIndex: 0,
        tickCount: tickCount,
        isReview: false,
        selectedOption: List.generate(questions.length, (_) => null),
        answeredStatus: List.generate(questions.length, (_) => false),
      ),
    );
  }

  Future<void> _answerQuestion(
    AnswerQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final updateSelectedAnswer = [...currentState.selectedOption];
      updateSelectedAnswer[currentState.currentIndex] = event.index;
      var correct =
          currentState.questions[currentState.currentIndex].correctAnswer ==
          updateSelectedAnswer[currentState.currentIndex];
      final updatedAnsweredStatus = [...currentState.answeredStatus];
      updatedAnsweredStatus[currentState.currentIndex] = true;
      emit(
        currentState.copyWith(
          answeredStatus: updatedAnsweredStatus,
          selectedOption: updateSelectedAnswer,
        ),
      );
    }
  }

  Future<void> _nextQuestion(
    NextQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.questions.length) {
        emit(currentState.copyWith(currentIndex: nextIndex));
      }
    }
  }

  Future<void> _prevQuestion(
    PrevQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final prevIndex = currentState.currentIndex - 1;
      if (prevIndex >= 0) {
        emit(currentState.copyWith(currentIndex: prevIndex));
      }
    }
  }

  Future<void> _jumpToQuestion(
    JumpToQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final index = event.index;
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  Future<void> _onTimerTicked(
    TimerTicked event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      emit(currentState.copyWith(tickCount: event.remainingSeconds));
    }
  }

  Future<void> _onSubmit(SubmitTest event, Emitter<QuestionState> emit) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final totalQuestions = currentState.questions.length;
      final selectedOptions = currentState.selectedOption;
      final answeredStatus = currentState.answeredStatus;

      final attempted = answeredStatus.where((status) => status).length;
      final notAttempted = answeredStatus.where((status) => !status).length;
      final timeSpent = 30 - currentState.tickCount ~/ 60;
      int correctAnswers = 0;
      int incorrectAnswers = 0;
      for (int i = 0; i < currentState.questions.length; i++) {
        final userAnswer = selectedOptions[i];
        final correctAnswer = currentState.questions[i].correctAnswer;

        if (userAnswer != null) {
          if (userAnswer.trim() == correctAnswer.trim()) {
            correctAnswers++;
          } else {
            incorrectAnswers++;
          }
        }
      }
      emit(
        TestSubmitted(
          answeredStatus: answeredStatus,
          questions: currentState.questions,
          selectedOption: selectedOptions,
          totalQuestions: totalQuestions,
          attempted: attempted,
          notAttempted: notAttempted,
          correct: correctAnswers,
          inCorrect: incorrectAnswers,
          timeSpent: timeSpent,
        ),
      );
    }
    timer?.cancel();
  }

  Future<void> _onReviewTest(
    ReviewTestMode event,
    Emitter<QuestionState> emit,
  ) async {
    emit(
      QuestionLoaded(
        questions: event.questions,
        currentIndex: 0,
        answeredStatus: event.answeredStatus,
        selectedOption: event.selectedOption,
        tickCount: 0,
        isReview: true,
      ),
    );
  }
}
