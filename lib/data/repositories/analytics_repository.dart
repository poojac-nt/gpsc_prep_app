import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_model.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_screen_model.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/domain/entities/trend_result_model.dart';

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

  Future<Either<Failure, OverAllAnalyticsModel>> fetchOverAllAnalytics({
    DateTime? from,
    DateTime? to,
  }) async => await _supabase.fetchOverAllAnalytics(from: from, to: to);

  Future<Either<Failure, TrendResultModel>> fetchTrendForUser() async =>
      await _supabase.fetchTrendForUser();

  Future<Either<Failure, List<LeaderboardModel>>> getToppers() async =>
      await _supabase.getToppers();

  Future<Either<Failure, LeaderboardScreenModel>> getTop3Scorers() async =>
      await _supabase.getTop3Scorers();
}
