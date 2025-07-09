import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';

import '../../../../core/di/di.dart';
import '../../../../core/helpers/log_helper.dart';
import '../../../../domain/entities/question_language_model.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  Timer? timer;
  TestRepository _testRepository;
  final log = getIt<LogHelper>();
  List<String> questionType = [];

  QuestionBloc(this._testRepository) : super(QuestionLoading()) {
    on<LoadQuestion>(_loadQuestion);
    on<SubmitTest>(_onSubmit);
    on<ReviewTestEvent>(_onReviewTest);
    on<AnswerQuestion>(_answerQuestion);
    on<NextQuestion>(_nextQuestion);
    on<PrevQuestion>(_prevQuestion);
    on<JumpToQuestion>(_jumpToQuestion);
  }

  Future<void> _loadQuestion(
    LoadQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    final result = await _testRepository.fetchTestQuestions(event.testId);

    result.fold(
      (failure) {
        print("Failed to load questions: $failure");
        emit(QuestionLoadFailed(failure));
      },
      (questions) {
        List<QuestionLanguageData> localizedQuestions = [];
        List<String> questionType = [];

        switch (event.language) {
          case 'hi':
            localizedQuestions =
                questions
                    .map((e) => e.questionHi)
                    .whereType<QuestionLanguageData>()
                    .toList();
            break;
          case 'en':
            localizedQuestions =
                questions
                    .map((e) => e.questionEn)
                    .whereType<QuestionLanguageData>()
                    .toList();
            break;
          case 'gj':
            localizedQuestions =
                questions
                    .map((e) => e.questionGj)
                    .whereType<QuestionLanguageData>()
                    .toList();
            break;
          default:
            emit(QuestionLoadFailed(Failure("Unsupported language")));
            return;
        }

        questionType = questions.map((e) => e.questionType).toList();

        if (localizedQuestions.isEmpty) {
          emit(
            QuestionLoadFailed(
              Failure("No questions available in selected language"),
            ),
          );
          return;
        }

        for (var q in questions) {
          log.i("Question type: ${q.questionType}");
          log.i("EN Question: ${q.questionEn.questionTxt}");
        }
        emit(
          QuestionLoaded(
            questions: localizedQuestions,
            questionType: questionType,
            currentIndex: 0,
            isReview: false,
            selectedOption: List.generate(
              localizedQuestions.length,
              (_) => null,
            ),
            answeredStatus: List.generate(
              localizedQuestions.length,
              (_) => false,
            ),
          ),
        );
      },
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
      List<bool?> isCorrect = [];
      for (int i = 0; i < currentState.questions.length; i++) {
        final userAnswer = selectedOptions[i];
        final correctAnswer = currentState.questions[i].correctAnswer;

        if (userAnswer != null) {
          if (userAnswer.trim() == correctAnswer.trim()) {
            correctAnswers++;
            isCorrect.add(true);
          } else {
            incorrectAnswers++;
            isCorrect.add(false);
          }
        }
      }
      emit(
        TestSubmitted(
          answeredStatus: answeredStatus,
          questions: currentState.questions,
          selectedOption: selectedOptions,
          totalQuestions: totalQuestions,
          questionType: currentState.questionType,
          attempted: attempted,
          notAttempted: notAttempted,
          correct: correctAnswers,
          inCorrect: incorrectAnswers,
          isCorrect: isCorrect,
          isReview: currentState.isReview,
        ),
      );
    }
    timer?.cancel();
  }

  Future<void> _onReviewTest(
    ReviewTestEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(
      QuestionLoaded(
        questions: event.questions,
        currentIndex: 0,
        questionType: event.questionType,
        answeredStatus: event.answeredStatus,
        selectedOption: event.selectedOption,
        isReview: true,
      ),
    );
  }
}
