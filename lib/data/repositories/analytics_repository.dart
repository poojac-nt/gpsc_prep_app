import 'package:either_dart/either.dart';

import '../../core/error/failure.dart';
import '../../core/helpers/supabase_helper.dart';
import '../../domain/entities/attempted_question_stats_model.dart';
import '../../domain/entities/dashboard_analytics.dart';

class AnalyticsRepository {
  final SupabaseHelper _supabase;
  AnalyticsRepository(this._supabase);

  Future<Either<Failure, DashboardAnalytics>> getDashboardAnalytics() async =>
      await _supabase.getDashboardAnalytics();

  Future<Either<Failure, List<Map<String, dynamic>>>>
  fetchQuestionCorrectnessCounts(int testId) async {
    return await _supabase.fetchTestQuestionCorrectness(testId);
  }

  Future<Either<Failure, List<AttemptedQuestionStat>>> fetchAttemptedCounts(
    int testId,
  ) async => await _supabase.fetchAttemptedQuestionStats(testId);
}
