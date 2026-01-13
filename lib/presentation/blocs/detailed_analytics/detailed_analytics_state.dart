part of 'detailed_analytics_bloc.dart';

class DetailedAnalyticsState {
  final List<Difficulty> difficultyData;
  final List<Difficulty> questionTypeData;
  final List<SubjectScore> subjectData;
  final String? overallAccuracy;
  final bool isLoading;
  final Failure? error;

  DetailedAnalyticsState({
    required this.difficultyData,
    required this.questionTypeData,
    required this.subjectData,
    this.overallAccuracy,
    this.isLoading = false,
    this.error,
  });

  factory DetailedAnalyticsState.initial({
    List<Difficulty>? initialDifficulty,
    List<Difficulty>? initialQuestionTypes,
    List<SubjectScore>? initialSubjects,
  }) {
    return DetailedAnalyticsState(
      difficultyData: initialDifficulty ?? [],
      questionTypeData: initialQuestionTypes ?? [],
      subjectData: initialSubjects ?? [],
      isLoading: false,
    );
  }

  DetailedAnalyticsState copyWith({
    List<Difficulty>? difficultyData,
    List<Difficulty>? questionTypeData,
    List<SubjectScore>? subjectData,
    String? overallAccuracy,
    bool? isLoading,
    Failure? error,
  }) {
    return DetailedAnalyticsState(
      difficultyData: difficultyData ?? this.difficultyData,
      questionTypeData: questionTypeData ?? this.questionTypeData,
      subjectData: subjectData ?? this.subjectData,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
