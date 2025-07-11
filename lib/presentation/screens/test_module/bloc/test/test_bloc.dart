import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_state.dart';
import 'package:meta/meta.dart';

part 'test_event.dart';
part 'test_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository _testRepository;
  final CacheManager _cacheManager = getIt<CacheManager>();

  TestBloc(this._testRepository) : super(TestResultInitial()) {
    on<SubmitTest>(_onSubmit);
    on<FetchSingleTestResultEvent>(_onFetchSingleResult);
  }

  Future<void> _onSubmit(SubmitTest event, Emitter<TestState> emit) async {
    final questions = event.questions;
    final selectedOptions = event.selectedOptions;
    final answeredStatus = event.answeredStatus;
    final totalQuestions = questions.length;

    final attempted = answeredStatus.where((status) => status).length;
    final notAttempted = totalQuestions - attempted;
    var timerState = getIt<TimerBloc>().state;
    final minSpent = timerState is TimerStopped ? timerState.totalMins : 0;
    final secSpent = timerState is TimerStopped ? timerState.totalSecs : 0;
    final timeSpent = (minSpent * 60) + secSpent;

    int correctAnswers = 0;
    int incorrectAnswers = 0;
    List<bool?> isCorrect = [];

    for (int i = 0; i < questions.length; i++) {
      final userAnswer = selectedOptions[i];
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
      totalQuestions: totalQuestions,
      wrongAnswers: incorrectAnswers,
    );
    emit(
      TestSubmitted(
        questions: questions,
        selectedOption: selectedOptions,
        answeredStatus: answeredStatus,
        totalQuestions: totalQuestions,
        attempted: attempted,
        notAttempted: notAttempted,
        correct: correctAnswers,
        inCorrect: incorrectAnswers,
        isCorrect: isCorrect,
        isReview: false,
      ),
    );
    _testRepository.insertTestResult(
      TestResultModel(
        userId: getIt<CacheManager>().user!.id!,
        testId: event.testId,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        inCorrectAnswers: incorrectAnswers,
        attemptedQuestions: attempted,
        notAttemptedQuestions: notAttempted,
        score: totalScore,
        timeTaken: timeSpent,
      ),
    );
  }

  Future<void> _onFetchSingleResult(
    FetchSingleTestResultEvent event,
    Emitter<TestState> emit,
  ) async {
    emit(SingleResultLoading());

    final result = await _testRepository.singleTestResult(event.testId);

    result.fold(
      (failure) => emit(SingleResultFailure(failure)),
      (data) => emit(SingleResultSuccess(data!)),
    );
  }
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
