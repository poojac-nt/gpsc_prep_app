import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/entities/question_language_model.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  QuestionBloc() : super(QuestionInitial()) {
    on<LoadQuestion>(_loadQuestion);
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
    List<QuestionLanguageData> questions = [
      QuestionLanguageData(
        questionTxt: 'What is Flutter ?',
        optA: "A. Flutter is a framework",
        optB: "B. Flutter is a programming language",
        optC: " C. Flutter is a widget library",
        optD: "D. Flutter is a mobile app development platform",
        correctAnswer: "D. Flutter is a mobile app development platform",
        explanation:
            "Flutter is not a programming language — it’s a mobile app development framework created by Google. It allows developers to build cross-platform apps using a single codebase in Dart, making it faster and more efficient to develop for Android, iOS, and other platforms.",
      ),
      QuestionLanguageData(
        questionTxt: """
          **Match the followning options to countries**
          | Column A | Column B |
          | --- | --- |
          | 1. Delhi | a. State |
          | 2. India | b. Country |
          | 3. America | c. America |
          """,
        optA: "A. 1-A,2-B,3-C",
        optB: "B. 3-A,2-B,1-C",
        optC: "C. 2-A,3-B,C-1",
        optD: "D. 2-C,3-A,1-B",
        correctAnswer: " B. 3-A,2-B,1-C",
        explanation:
            "Mitochondria are known as the powerhouse of the cell because they generate energy (ATP) through cellular respiration. This energy is essential for all cell activities.",
      ),
      QuestionLanguageData(
        questionTxt:
            """ **Consider the following statements regarding the Indus Valley Civilization:**
      1. The civilization was primarily urban in nature.
      2. The people of Indus Valley Civilization used iron extensively.
      3. Harappa and Mohenjo-Daro were major cities of this civilization.
      4. The script used by them has been successfully deciphered.
      """,
        optA: " A. 1, 2 and 3 only",
        optB: "B. 1 and 3 only",
        optC: "C. 2, 3 and 4 only",
        optD: "D. 1,2 3 and 4",
        correctAnswer: "C. 2, 3 and 4 only",
        explanation:
            "Flutter is not a programming language — it’s a mobile app development framework created by Google. It allows developers to build cross-platform apps using a single codebase in Dart, making it faster and more efficient to develop for Android, iOS, and other platforms.",
      ),
      QuestionLanguageData(
        questionTxt: "**The powerhouse of the cell is the _________**",
        optA: "A. Nucleus",
        optB: "B. Mitochondria",
        optC: "C. Ribosome",
        optD: "D. Cytoplasm",
        correctAnswer: "D. Cytoplasm",
        explanation:
            "Mitochondria are known as the powerhouse of the cell because they generate energy (ATP) through cellular respiration. This energy is essential for all cell activities.",
      ),
    ];

    emit(
      QuestionLoaded(
        questions: questions,
        currentIndex: 0,
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

  Future<void> _onSubmit(SubmitTest event, Emitter<QuestionState> emit) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final totalQuestions = currentState.questions.length;
      final selectedOptions = currentState.selectedOption;
      final answeredStatus = currentState.answeredStatus;

      final attempted = answeredStatus.where((status) => status).length;
      final notAttempted = answeredStatus.where((status) => !status).length;
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
          isReview: currentState.isReview,
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
        isReview: true,
      ),
    );
  }
}
