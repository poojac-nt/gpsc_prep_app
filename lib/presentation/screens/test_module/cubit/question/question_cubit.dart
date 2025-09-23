import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';

import '../../../../../domain/entities/question_language_model.dart';

class QuestionCubit extends Cubit<QuestionCubitState> {
  QuestionCubit() : super(QuestionCubitInitial());
  final bool _isQuitTest = false;

  void reset() {
    emit(QuestionCubitInitial());
  }

  /// Call this after Bloc loads questions
  void initialize(
    List<QuestionLanguageData> questions,
    List<QuestionModel> questionModel,
  ) {
    if (state is McqQuestionCubitLoaded) return;

    emit(
      McqQuestionCubitLoaded(
        questionModel: questionModel,
        questions: questions,
        currentIndex: 0,
        selectedOption: List.generate(questions.length, (_) => null),
        answeredStatus: List.generate(questions.length, (_) => false),
        isQuitTest: _isQuitTest,
      ),
    );
  }

  void answerQuestion(String? option) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    final updatedSelected = List<String?>.from(currentState.selectedOption)
      ..[currentState.currentIndex] = option;

    final updatedStatus = List<bool>.from(currentState.answeredStatus)
      ..[currentState.currentIndex] = option != null;

    emit(
      currentState.copyWith(
        selectedOption: updatedSelected,
        answeredStatus: updatedStatus,
      ),
    );
  }

  void nextQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    if (currentState.currentIndex < currentState.questions.length - 1) {
      emit(currentState.copyWith(currentIndex: currentState.currentIndex + 1));
    }
  }

  void prevQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    if (currentState.currentIndex > 0) {
      emit(currentState.copyWith(currentIndex: currentState.currentIndex - 1));
    }
  }

  void jumpToQuestion(int index) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    if (index >= 0 && index < currentState.questions.length) {
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  void reviewTest({
    required List<bool> answeredStatus,
    required List<String?> selectedOption,
    required List<bool?> isCorrect,
    required List<QuestionLanguageData> questions,
  }) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    emit(
      currentState.copyWith(
        questions: questions,
        currentIndex: 0,
        answeredStatus: answeredStatus,
        selectedOption: selectedOption,
        isCorrect: isCorrect,
        isReview: true,
      ),
    );
  }
}
