import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:meta/meta.dart';

part 'detailed_analytics_event.dart';
part 'detailed_analytics_state.dart';

class DetailedAnalyticsBloc
    extends Bloc<DetailedAnalyticsEvent, DetailedAnalyticsState> {
  final AnalyticsRepository repository;

  DetailedAnalyticsBloc({
    required this.repository,
    List<Difficulty>? initialDifficulty,
    List<Difficulty>? initialQuestionTypes,
    List<SubjectScore>? initialSubjects,
  }) : super(
         DetailedAnalyticsState.initial(
           initialDifficulty: initialDifficulty,
           initialQuestionTypes: initialQuestionTypes,
           initialSubjects: initialSubjects,
         ),
       ) {
    on<LoadDetailedDifficultyEvent>(_onLoadDifficulty);
    on<LoadDetailedQuestionTypeEvent>(_onLoadQuestionType);
    on<LoadDetailedSubjectEvent>(_onLoadSubject);
    on<ResetDetailedAnalyticsEvent>(
      (event, emit) => emit(DetailedAnalyticsState.initial()),
    );
  }

  Future<void> _onLoadDifficulty(
    LoadDetailedDifficultyEvent event,
    Emitter<DetailedAnalyticsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repository.fetchOverAllAnalytics(
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (data) => emit(
        state.copyWith(
          isLoading: false,
          difficultyData: data.difficulty,
          overallAccuracy: data.userAccuracyOverall,
        ),
      ),
    );
  }

  Future<void> _onLoadQuestionType(
    LoadDetailedQuestionTypeEvent event,
    Emitter<DetailedAnalyticsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repository.fetchOverAllAnalytics(
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (data) => emit(
        state.copyWith(isLoading: false, questionTypeData: data.questionType),
      ),
    );
  }

  Future<void> _onLoadSubject(
    LoadDetailedSubjectEvent event,
    Emitter<DetailedAnalyticsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repository.fetchOverAllAnalytics(
      from: event.from,
      to: event.to,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (data) => emit(
        state.copyWith(isLoading: false, subjectData: data.subjectScores),
      ),
    );
  }
}
