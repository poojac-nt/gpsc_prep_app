import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/attempted_question_stats_model.dart';

part 'pie_chart_event.dart';
part 'pie_chart_state.dart';

class PieChartBloc extends Bloc<PieChartEvent, PieChartState> {
  final AnalyticsRepository _analyticsRepository;

  PieChartBloc(this._analyticsRepository) : super(PieChartInitial()) {
    on<FetchPerformanceSummary>(_onFetchPerformanceSummary);
  }

  Future<void> _onFetchPerformanceSummary(
    FetchPerformanceSummary event,
    Emitter<PieChartState> emit,
  ) async {
    emit(PerformanceSummaryLoading());

    try {
      // Run both database queries concurrently for efficiency
      final results = await Future.wait([
        _analyticsRepository.fetchQuestionCorrectnessCounts(event.testId),
        _analyticsRepository.fetchAttemptedCounts(event.testId),
      ]);

      // Extract results from the completed futures
      final correctnessResult = results[0];
      final attemptedResult = results[1];

      // Use pattern matching on the results to handle success/failure
      switch ((correctnessResult, attemptedResult)) {
        case (Right(value: final correct), Right(value: final attempted)):
          emit(
            PieChartResultSuccess(
              correctnessCounts: correct as List<Map<String, dynamic>>,
              attemptedCounts: List<AttemptedQuestionStat>.from(attempted),
            ),
          );

        case (Left(value: final failure), _):
          emit(PieChartResultFailure(failure));

        case (_, Left(value: final failure)):
          emit(PieChartResultFailure(failure));
      }
    } catch (e) {
      // Catch any unexpected errors during the process
      emit(PieChartResultFailure(Failure(e.toString())));
    }
  }
}
