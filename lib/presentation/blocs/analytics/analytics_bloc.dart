import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/date_range_helper.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/domain/entities/trend_result_model.dart';
import 'package:gpsc_prep_app/utils/enums/date_range_enum.dart';
import 'package:meta/meta.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;
  OverAllAnalyticsModel? _cachedAnalytics;
  AnalyticsRange? _cachedRange;

  AnalyticsBloc(this.repository) : super(AnalyticsState.initial()) {
    on<LoadSubjectMasteryEvent>(_loadSubjectMastery);
    on<LoadDifficultyAnalyticsEvent>(_loadDifficulty);
    on<LoadQuestionTypeAnalyticsEvent>(_loadQuestionTypes);
    on<FetchTrendData>(_fetchTrendData);
    on<ResetAnalyticsEvent>(_onReset);
  }

  void _onReset(ResetAnalyticsEvent event, Emitter<AnalyticsState> emit) {
    _cachedAnalytics = null;
    _cachedRange = null;
    _fetchingFuture = null;
    _fetchingRange = null;
    emit(AnalyticsState.initial());
  }

  Future<dynamic>? _fetchingFuture;
  AnalyticsRange? _fetchingRange;

  Future<OverAllAnalyticsModel?> _getAnalytics(
    AnalyticsRange range,
    Emitter<AnalyticsState> emit,
  ) async {
    if (_cachedAnalytics != null && _cachedRange == range) {
      return _cachedAnalytics;
    }

    if (_fetchingFuture != null && _fetchingRange == range) {
      final result = await _fetchingFuture;
      return _handleResult(result, range, emit);
    }

    _fetchingRange = range;
    final dateRange = AnalyticsDateRangeHelper.calculate(range);

    _fetchingFuture = repository.fetchOverAllAnalytics(
      from: dateRange.from,
      to: dateRange.to,
    );

    final result = await _fetchingFuture;
    _fetchingFuture = null;
    _fetchingRange = null;

    return _handleResult(result, range, emit);
  }

  OverAllAnalyticsModel? _handleResult(
    dynamic result,
    AnalyticsRange range,
    Emitter<AnalyticsState> emit,
  ) {
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            subjectMastery: state.subjectMastery.copyWith(
              isLoading: false,
              error: failure,
            ),
            difficulty: state.difficulty.copyWith(
              isLoading: false,
              error: failure,
            ),
            questionTypes: state.questionTypes.copyWith(
              isLoading: false,
              error: failure,
            ),
          ),
        );
        return null;
      },
      (data) {
        _cachedAnalytics = data;
        _cachedRange = range;
        return data;
      },
    );
  }

  /* ---------------- SUBJECT MASTERY ---------------- */
  Future<void> _loadSubjectMastery(
    LoadSubjectMasteryEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(
      state.copyWith(
        subjectMastery: state.subjectMastery.copyWith(
          isLoading: true,
          range: event.range,
        ),
      ),
    );

    final analytics = await _getAnalytics(event.range, emit);

    if (analytics == null) return;

    emit(
      state.copyWith(
        subjectMastery: state.subjectMastery.copyWith(
          isLoading: false,
          data: analytics.subjectScores,
        ),
      ),
    );
  }

  /* ---------------- DIFFICULTY ---------------- */

  Future<void> _loadDifficulty(
    LoadDifficultyAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(
      state.copyWith(
        difficulty: state.difficulty.copyWith(
          isLoading: true,
          range: event.range,
        ),
      ),
    );

    final analytics = await _getAnalytics(event.range, emit);
    if (analytics == null) return;

    emit(
      state.copyWith(
        difficulty: state.difficulty.copyWith(
          isLoading: false,
          data: analytics.difficulty,
          overallAccuracy: analytics.userAccuracyOverall,
        ),
      ),
    );
  }

  /* ---------------- QUESTION TYPES ---------------- */

  Future<void> _loadQuestionTypes(
    LoadQuestionTypeAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(
      state.copyWith(
        questionTypes: state.questionTypes.copyWith(
          isLoading: true,
          range: event.range,
        ),
      ),
    );

    final analytics = await _getAnalytics(event.range, emit);
    if (analytics == null) return;

    emit(
      state.copyWith(
        questionTypes: state.questionTypes.copyWith(
          isLoading: false,
          data: analytics.questionType,
        ),
      ),
    );
  }

  /* ---------------- TREND DATA ---------------- */
  Future<void> _fetchTrendData(
    FetchTrendData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(
      state.copyWith(
        trendData: TrendDataState(isLoading: true, data: state.trendData.data),
      ),
    );

    final result = await repository.fetchTrendForUser();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            trendData: TrendDataState(
              isLoading: false,
              data: null,
              error: failure,
            ),
          ),
        );
      },
      (trendData) {
        emit(
          state.copyWith(
            trendData: TrendDataState(isLoading: false, data: trendData),
          ),
        );
      },
    );
  }
}
