import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/domain/entities/prelims_test_progress.dart';
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

  void initialize(
    List<QuestionLanguageData> questions,
    List<QuestionModel> questionModel,
    String language, {
    List<String> allowedLanguages = const [],
  }) {
    if (state is McqQuestionCubitLoaded) return;
    _currentNavigatorPage = 0;
    emit(
      McqQuestionCubitLoaded(
        questionModel: questionModel,
        questions: questions,
        currentIndex: 0,
        selectedOption: List.generate(questions.length, (_) => null),
        answeredStatus: List.generate(questions.length, (_) => false),
        timePerQuestion: List.generate(questions.length, (_) => 0),
        currentQuestionStartTime: DateTime.now().millisecondsSinceEpoch,
        isQuitTest: _isQuitTest,
        currentLanguage: language,
        allowedLanguages: allowedLanguages,
      ),
    );
  }

  void switchLanguage(String newLanguage) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    final allowed = currentState.allowedLanguages;
    if (allowed.isNotEmpty && !allowed.contains(newLanguage)) return;

    // Extract questions in the new language
    List<QuestionLanguageData> localizedQuestions;
    switch (newLanguage) {
      case 'hi':
        localizedQuestions = currentState.questionModel
            .map((e) => e.questionHi)
            .whereType<QuestionLanguageData>()
            .toList();
        break;
      case 'en':
        localizedQuestions = currentState.questionModel
            .map((e) => e.questionEn)
            .whereType<QuestionLanguageData>()
            .toList();
        break;
      case 'gj':
        localizedQuestions = currentState.questionModel
            .map((e) => e.questionGj)
            .whereType<QuestionLanguageData>()
            .toList();
        break;
      default:
        return;
    }

    if (localizedQuestions.isEmpty) return;

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

  void answerQuestionAt(int index, String? option) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    if (index < 0 || index >= currentState.questions.length) return;

    // Convert option text to identifier (A, B, C, D)
    String? optionIdentifier;
    if (option != null) {
      final questionAtIndex = currentState.questions[index];
      optionIdentifier = _getOptionIdentifier(option, questionAtIndex);
    }

    final updatedSelected = List<String?>.from(currentState.selectedOption);
    updatedSelected[index] = optionIdentifier;

    final updatedStatus = List<bool>.from(currentState.answeredStatus);
    updatedStatus[index] = option != null;

    emit(
      currentState.copyWith(
        selectedOption: updatedSelected,
        answeredStatus: updatedStatus,
      ),
    );
  }

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
      return 'a';
    }
    if (trimmed == trimmedB) {
      return 'b';
    }
    if (trimmed == trimmedC) {
      return 'c';
    }
    if (trimmed == trimmedD) {
      return 'd';
    }
    return null;
  }

  void nextQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    _updateTimeSpent();

    if (currentState.currentIndex < currentState.questions.length - 1) {
      final newIndex = currentState.currentIndex + 1;
      _currentNavigatorPage = newIndex ~/ navigatorPageSize;

      emit(
        (state as McqQuestionCubitLoaded).copyWith(
          currentIndex: newIndex,
          currentQuestionStartTime: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  void prevQuestion() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    _updateTimeSpent();

    if (currentState.currentIndex > 0) {
      final newIndex = currentState.currentIndex - 1;
      _currentNavigatorPage = newIndex ~/ navigatorPageSize;

      emit(
        (state as McqQuestionCubitLoaded).copyWith(
          currentIndex: newIndex,
          currentQuestionStartTime: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  void jumpToQuestion(int index) {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    _updateTimeSpent();

    if (index >= 0 && index < currentState.questions.length) {
      _currentNavigatorPage = index ~/ navigatorPageSize;
      emit(
        (state as McqQuestionCubitLoaded).copyWith(
          currentIndex: index,
          currentQuestionStartTime: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  void _updateTimeSpent() {
    if (state is! McqQuestionCubitLoaded) return;
    final currentState = state as McqQuestionCubitLoaded;

    if (currentState.currentQuestionStartTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds =
          (now - currentState.currentQuestionStartTime!) ~/ 1000;

      final updatedTimePerQuestion = List<int>.from(
        currentState.timePerQuestion,
      );

      // Ensure the list is long enough
      if (updatedTimePerQuestion.length <= currentState.currentIndex) {
        final missingCount =
            currentState.currentIndex - updatedTimePerQuestion.length + 1;
        updatedTimePerQuestion.addAll(List.filled(missingCount, 0));
      }

      updatedTimePerQuestion[currentState.currentIndex] += elapsedSeconds;

      emit(currentState.copyWith(timePerQuestion: updatedTimePerQuestion));
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

  // ===== PRELIMS TEST PROGRESS METHODS =====

  /// Save progress (Prelims tests only)
  Future<void> savePrelimsProgress({
    required int userId,
    required int testId,
    required String languageCode,
    required int remainingTimeInSeconds,
  }) async {
    final currentState = state;
    if (currentState is! McqQuestionCubitLoaded) return;

    final progressRepo = getIt<PrelimsProgressRepository>();
    final progress = PrelimsTestProgress(
      userId: userId,
      testId: testId,
      languageCode: languageCode,
      currentQuestionIndex: currentState.currentIndex,
      selectedOptions: currentState.selectedOption,
      answeredStatus: currentState.answeredStatus,
      remainingTimeInSeconds: remainingTimeInSeconds,
      savedAt: DateTime.now().toIso8601String(),
      totalQuestions: currentState.questions.length,
      timePerQuestion: currentState.timePerQuestion,
    );

    await progressRepo.saveProgress(progress);
  }

  /// Load progress (Prelims tests only)
  bool loadPrelimsProgress(int userId, int testId) {
    final progressRepo = getIt<PrelimsProgressRepository>();
    final progress = progressRepo.getProgress(userId, testId);

    if (progress == null || progress.isExpired()) {
      return false; // No valid progress found
    }

    final currentState = state;
    if (currentState is! McqQuestionCubitLoaded) return false;

    // Update navigator page based on restored index
    _currentNavigatorPage = progress.currentQuestionIndex ~/ navigatorPageSize;
    emit(
      McqQuestionCubitLoaded(
        questionModel: currentState.questionModel,
        questions: currentState.questions,
        currentIndex: progress.currentQuestionIndex,
        selectedOption: progress.selectedOptions,
        answeredStatus: progress.answeredStatus,
        timePerQuestion: progress.timePerQuestion,
        currentQuestionStartTime: DateTime.now().millisecondsSinceEpoch,
        currentLanguage: progress.languageCode,
        allowedLanguages: currentState.allowedLanguages,
        isReview: false,
      ),
    );

    return true; // Successfully loaded progress
  }

  /// Clear saved progress
  Future<void> clearPrelimsProgress(int userId, int testId) async {
    final progressRepo = getIt<PrelimsProgressRepository>();
    await progressRepo.deleteProgress(userId, testId);
  }

  // ===== END PRELIMS PROGRESS METHODS =====

  void reviewTest({
    required List<bool> answeredStatus,
    required List<String?> selectedOption,
    required List<bool?> isCorrect,
    required List<QuestionLanguageData> questions,
    required List<int> timePerQuestion,
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
        timePerQuestion: timePerQuestion,
        isReview: true,
      ),
    );
  }
}
