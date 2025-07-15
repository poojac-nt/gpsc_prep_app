import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';

import '../../../../../core/di/di.dart';
import '../../../../../domain/entities/question_language_model.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';

class TestCubit extends Cubit<TestCubitSubmitted> {
  TestCubit() : super(TestCubitSubmitted.initial());

  void calculateAndEmitTestResult({
    required List<QuestionLanguageData> questions,
    required List<String?> selectedOption,
    required List<bool> answeredStatus,
    required List<int> marks,
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
    double totalScore = 0.0;

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedOption[i];
      final correctAnswer = questions[i].correctAnswer;

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
}
