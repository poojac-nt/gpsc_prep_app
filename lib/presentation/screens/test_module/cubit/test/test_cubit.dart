import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';

import '../../../../../core/di/di.dart';
import '../../../../../domain/entities/question_language_model.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';

class TestCubit extends Cubit<TestCubitState> {
  TestCubit() : super(TestCubitInitial());

  void calculateAndEmitTestResult({
    required List<QuestionLanguageData> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
  }) {
    final attempted = answeredStatus.where((status) => status).length;
    final notAttempted = questions.length - attempted;
    var timerState = getIt<TimerBloc>().state;
    final minSpent = timerState is TimerStopped ? timerState.totalMins : 0;
    final secSpent = timerState is TimerStopped ? timerState.totalSecs : 0;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    List<bool?> isCorrect = [];

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedOption[i];
      final correctAnswer = questions[i].correctAnswer;

      if (userAnswer != null) {
        if (userAnswer.trim() == correctAnswer.trim()) {
          correctAnswers++;
          isCorrect.add(true);
        } else {
          incorrectAnswers++;
          isCorrect.add(false);
        }
      } else {
        isCorrect.add(null);
      }
    }

    final totalScore = calculatePercentage(
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      wrongAnswers: incorrectAnswers,
    );
    emit(
      TestCubitSubmitted(
        questions: questions,
        selectedOption: selectedOption,
        answeredStatus: answeredStatus,
        isCorrect: isCorrect,
        totalQuestions: questions.length,
        attempted: attempted,
        notAttempted: notAttempted,
        correct: correctAnswers,
        inCorrect: incorrectAnswers,
        isReview: false,
        score: totalScore,
        timeSpent: timeSpent,
      ),
    );
  }

  double calculatePercentage({
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
  }) {
    const double marksPerCorrect = 2.0;
    const double negativeMarkFraction = 0.33;

    // Calculate not attempted
    int notAttempted = totalQuestions - correctAnswers - wrongAnswers;

    // Ensure values are logical
    if (notAttempted < 0) {
      throw ArgumentError(
        'Total of correct and wrong answers cannot exceed total questions',
      );
    }

    // Score formula
    double score =
        (correctAnswers * marksPerCorrect) -
        (wrongAnswers * marksPerCorrect * negativeMarkFraction);

    double maxScore = totalQuestions * marksPerCorrect;

    // Avoid division by zero
    if (maxScore == 0) return 0.0;

    // Percentage score
    double percentage = (score / maxScore) * 100;

    return percentage.clamp(0.0, 100.0);
  }
}
