import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:meta/meta.dart';

part 'question_event.dart';
part 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final TestRepository _testRepository;
  final log = getIt<LogHelper>();

  QuestionBloc(this._testRepository) : super(QuestionLoading()) {
    on<LoadQuestion>(_loadQuestion);
    on<AnswerQuestion>(_answerQuestion);
    on<NextQuestion>(_nextQuestion);
    on<PrevQuestion>(_prevQuestion);
    on<JumpToQuestion>(_jumpToQuestion);
    on<ReviewTestEvent>(_onReviewTest);
  }

  Future<void> _loadQuestion(
    LoadQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    final result = await _testRepository.fetchTestQuestions(event.testId);

    result.fold((failure) => emit(QuestionLoadFailed(failure)), (questions) {
      List<QuestionLanguageData> localizedQuestions;
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

      if (localizedQuestions.isEmpty) {
        emit(
          QuestionLoadFailed(
            Failure("No questions available in selected language"),
          ),
        );
        return;
      }

      emit(
        QuestionLoaded(
          questions: localizedQuestions,
          currentIndex: 0,
          selectedOption: List.generate(localizedQuestions.length, (_) => null),
          answeredStatus: List.generate(
            localizedQuestions.length,
            (_) => false,
          ),
        ),
      );
    });
  }

  Future<void> _answerQuestion(
    AnswerQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final updatedSelected = [...currentState.selectedOption];
      updatedSelected[currentState.currentIndex] = event.index;

      final updatedStatus = [...currentState.answeredStatus];
      updatedStatus[currentState.currentIndex] = true;

      emit(
        currentState.copyWith(
          selectedOption: updatedSelected,
          answeredStatus: updatedStatus,
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
      emit(currentState.copyWith(currentIndex: event.index));
    }
  }

  Future<void> _onReviewTest(
    ReviewTestEvent event,
    Emitter<QuestionState> emit,
  ) async {
    emit(
      QuestionLoaded(
        questions: event.questions,
        currentIndex: 0,
        answeredStatus: event.answeredStatus,
        selectedOption: event.selectedOption,
        isCorrect: event.isCorrect,
        isReview: true,
      ),
    );
  }
}
