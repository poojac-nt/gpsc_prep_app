import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';

import '../../../../../domain/entities/question_language_model.dart';

class QuestionCubit extends Cubit<QuestionCubitState> {
  QuestionCubit() : super(QuestionCubitInitial());
  final bool _isQuitTest = false;
  static const int navigatorPageSize = 20;
  int _currentNavigatorPage = 0;

  void reset() {
    emit(QuestionCubitInitial());
  }

  /// Call this after Bloc loads questions
  void initialize(
    List<QuestionLanguageData> questions,
    List<QuestionModel> questionModel,
    String language,
  ) {
    if (state is McqQuestionCubitLoaded) return;
    _currentNavigatorPage = 0;
    emit(
      McqQuestionCubitLoaded(
        questionModel: questionModel,
        questions: questions,
        currentIndex: 0,
        selectedOption: List.generate(questions.length, (_) => null),
        answeredStatus: List.generate(questions.length, (_) => false),
        isQuitTest: _isQuitTest,
        currentLanguage: language,
      ),
    );
  }

  /// Switch language while preserving user progress
  void switchLanguage(String newLanguage) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    // Extract questions in the new language
    List<QuestionLanguageData> localizedQuestions;
    switch (newLanguage) {
      case 'hi':
        localizedQuestions =
            currentState.questionModel
                .map((e) => e.questionHi)
                .whereType<QuestionLanguageData>()
                .toList();
        break;
      case 'en':
        localizedQuestions =
            currentState.questionModel
                .map((e) => e.questionEn)
                .whereType<QuestionLanguageData>()
                .toList();
        break;
      case 'gj':
        localizedQuestions =
            currentState.questionModel
                .map((e) => e.questionGj)
                .whereType<QuestionLanguageData>()
                .toList();
        break;
      default:
        return;
    }

    if (localizedQuestions.isEmpty) return;

    // Update state with new language questions while preserving progress
    emit(
      currentState.copyWith(
        questions: localizedQuestions,
        currentLanguage: newLanguage,
      ),
    );
  }

  void answerQuestion(String? option) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    // Convert option text to identifier (A, B, C, D)
    String? optionIdentifier;
    if (option != null) {
      final currentQuestion = currentState.questions[currentState.currentIndex];
      optionIdentifier = _getOptionIdentifier(option, currentQuestion);
    }

    final updatedSelected = List<String?>.from(currentState.selectedOption)
      ..[currentState.currentIndex] = optionIdentifier;

    final updatedStatus = List<bool>.from(currentState.answeredStatus)
      ..[currentState.currentIndex] = option != null;

    emit(
      currentState.copyWith(
        selectedOption: updatedSelected,
        answeredStatus: updatedStatus,
      ),
    );
  }

  /// Helper method to get option identifier (A, B, C, D) from option text
  String? _getOptionIdentifier(
    String optionText,
    QuestionLanguageData questionData,
  ) {
    final trimmed = optionText.trim();

    // If it's already a single letter identifier, return it as is
    if (trimmed.length == 1) {
      final char = trimmed.toUpperCase();
      if (char == 'A' || char == 'B' || char == 'C' || char == 'D') {
        return trimmed;
      }
    }

    // Otherwise, match against the option text
    final trimmedA = questionData.optA.trim();
    final trimmedB = questionData.optB.trim();
    final trimmedC = questionData.optC.trim();
    final trimmedD = questionData.optD.trim();

    if (trimmed == trimmedA) {
      return _resolveCase(trimmedA, 'A', 'a');
    }
    if (trimmed == trimmedB) {
      return _resolveCase(trimmedB, 'B', 'b');
    }
    if (trimmed == trimmedC) {
      return _resolveCase(trimmedC, 'C', 'c');
    }
    if (trimmed == trimmedD) {
      return _resolveCase(trimmedD, 'D', 'd');
    }

    return null;
  }

  String _resolveCase(String optionText, String upper, String lower) {
    final trimmed = optionText.trim();
    if (trimmed.isEmpty) return upper;
    // Check if the original text started with a lowercase letter
    return trimmed[0] == trimmed[0].toLowerCase() ? lower : upper;
  }

  void nextQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    if (currentState.currentIndex < currentState.questions.length - 1) {
      final newIndex = currentState.currentIndex + 1;
      _currentNavigatorPage = newIndex ~/ navigatorPageSize;

      emit(currentState.copyWith(currentIndex: newIndex));
    }
  }

  void prevQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    if (currentState.currentIndex > 0) {
      final newIndex = currentState.currentIndex - 1;
      _currentNavigatorPage = newIndex ~/ navigatorPageSize;

      emit(currentState.copyWith(currentIndex: newIndex));
    }
  }

  void jumpToQuestion(int index) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    if (index >= 0 && index < currentState.questions.length) {
      _currentNavigatorPage = index ~/ navigatorPageSize;
      emit(currentState.copyWith(currentIndex: index));
    }
  }

  int get currentNavigatorPage => _currentNavigatorPage;

  int get navigatorStartIndex => _currentNavigatorPage * navigatorPageSize;

  int navigatorEndIndex(int totalQuestions) {
    final int end = navigatorStartIndex + navigatorPageSize;
    return end > totalQuestions ? totalQuestions : end;
  }

  List<int> visibleQuestionIndexes(int totalQuestions) {
    final start = navigatorStartIndex;
    final end = navigatorEndIndex(totalQuestions);
    return List.generate(end - start, (i) => start + i);
  }

  void reviewTest({
    required List<bool> answeredStatus,
    required List<String?> selectedOption,
    required List<bool?> isCorrect,
    required List<QuestionLanguageData> questions,
  }) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;
    _currentNavigatorPage = 0;
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
