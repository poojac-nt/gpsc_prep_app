part of 'analytics_bloc.dart';

@immutable
class AnalyticsState {
  final SubjectMasteryState subjectMastery;
  final DifficultyAnalyticsState difficulty;
  final QuestionTypeAnalyticsState questionTypes;
  final TrendDataState trendData;

  const AnalyticsState({
    required this.subjectMastery,
    required this.difficulty,
    required this.questionTypes,
    required this.trendData,
  });

  factory AnalyticsState.initial() {
    return AnalyticsState(
      subjectMastery: SubjectMasteryState.initial(),
      difficulty: DifficultyAnalyticsState.initial(),
      questionTypes: QuestionTypeAnalyticsState.initial(),
      trendData: TrendDataState.initial(),
    );
  }

  AnalyticsState copyWith({
    SubjectMasteryState? subjectMastery,
    DifficultyAnalyticsState? difficulty,
    QuestionTypeAnalyticsState? questionTypes,
    TrendDataState? trendData,
  }) {
    return AnalyticsState(
      subjectMastery: subjectMastery ?? this.subjectMastery,
      difficulty: difficulty ?? this.difficulty,
      questionTypes: questionTypes ?? this.questionTypes,
      trendData: trendData ?? this.trendData,
    );
  }
}

@immutable
class SubjectMasteryState {
  final bool isLoading;
  final List<SubjectScore> data;
  final Failure? error;

  const SubjectMasteryState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory SubjectMasteryState.initial() {
    return const SubjectMasteryState(isLoading: false, data: []);
  }

  SubjectMasteryState copyWith({
    bool? isLoading,
    List<SubjectScore>? data,
    Failure? error,
  }) {
    return SubjectMasteryState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

@immutable
class DifficultyAnalyticsState {
  final bool isLoading;
  final AnalyticsRange range;
  final List<Difficulty> data;
  final String overallAccuracy;
  final Failure? error;

  const DifficultyAnalyticsState({
    required this.isLoading,
    required this.range,
    required this.data,
    required this.overallAccuracy,
    this.error,
  });

  factory DifficultyAnalyticsState.initial() {
    return const DifficultyAnalyticsState(
      isLoading: false,
      range: AnalyticsRange.weekly,
      data: [],
      overallAccuracy: '0',
    );
  }

  DifficultyAnalyticsState copyWith({
    bool? isLoading,
    AnalyticsRange? range,
    List<Difficulty>? data,
    String? overallAccuracy,
    Failure? error,
  }) {
    return DifficultyAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      range: range ?? this.range,
      data: data ?? this.data,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      error: error,
    );
  }
}

@immutable
class QuestionTypeAnalyticsState {
  final bool isLoading;
  final AnalyticsRange range;
  final List<Difficulty> data;
  final Failure? error;

  const QuestionTypeAnalyticsState({
    required this.isLoading,
    required this.range,
    required this.data,
    this.error,
  });

  factory QuestionTypeAnalyticsState.initial() {
    return const QuestionTypeAnalyticsState(
      isLoading: false,
      range: AnalyticsRange.weekly,
      data: [],
    );
  }

  QuestionTypeAnalyticsState copyWith({
    bool? isLoading,
    AnalyticsRange? range,
    List<Difficulty>? data,
    Failure? error,
  }) {
    return QuestionTypeAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      range: range ?? this.range,
      data: data ?? this.data,
      error: error,
    );
  }
}

class TrendDataState {
  final bool isLoading;
  final TrendResultModel? data;
  final Failure? error;

  const TrendDataState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory TrendDataState.initial() {
    return const TrendDataState(isLoading: false, data: null);
  }

  TrendDataState copyWith({
    bool? isLoading,
    TrendResultModel? data,
    Failure? error,
  }) {
    return TrendDataState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
