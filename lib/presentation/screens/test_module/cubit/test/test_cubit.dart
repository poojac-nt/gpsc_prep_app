import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/utils/extensions/question_model_extension.dart';

class TestCubit extends Cubit<TestCubitSubmitted> {
  TestCubit() : super(TestCubitSubmitted.initial());

  void calculateAndEmitTestResult({
    required List<QuestionModel> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
    required List<int> marks,
    required int minSpent,
    required int secSpent,
    required String languageCode,
  }) {
    final attempted = answeredStatus.where((status) => status).length;
    final notAttempted = questions.length - attempted;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    List<bool?> isCorrect = [];
    double totalScore = 0.0;

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedOption[i];
      final correctAnswer =
          questions[i].getLanguageData(languageCode).correctAnswer;

      if (userAnswer != null) {
        if (userAnswer.trim() == correctAnswer.trim()) {
          correctAnswers++;
          isCorrect.add(true);
          totalScore += marks[i];
        } else {
          incorrectAnswers++;
          isCorrect.add(false);
          totalScore -= 0.33 * marks[i];
        }
      } else {
        isCorrect.add(null);
        totalScore += 0 * marks[i];
      }
    }
    emit(
      TestCubitSubmitted(
        questions: questions,
        selectedOption: selectedOption,
        answeredStatus: answeredStatus,
        isAnswerCorrect: isCorrect,
        totalQuestions: questions.length,
        attemptedQuestions: attempted,
        notAttemptedQuestions: notAttempted,
        correctAnswers: correctAnswers,
        inCorrectAnswers: incorrectAnswers,
        isReview: false,
        score: totalScore,
        timeSpent: timeSpent,
      ),
    );
  }
}
