import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/domain/entities/dashboard_analytics.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_model.dart';

import '../../../core/error/failure.dart';

part 'dashboard_bloc_event.dart';
part 'dashboard_bloc_state.dart';

class DashboardBloc extends Bloc<DashboardBlocEvent, DashboardBlocState> {
  final AnalyticsRepository _analyticsRepository;

  DashboardBloc(this._analyticsRepository)
    : super(FetchingDashboardAnalytics()) {
    on<FetchDashboardAnalytics>(_fetchAttemptedTests);
    on<DashBoardInitial>((event, emit) {
      emit(DashBoardInitialState());
    });
  }

  Future<void> _fetchAttemptedTests(
    DashboardBlocEvent event,
    Emitter<DashboardBlocState> emit,
  ) async {
    emit(FetchingDashboardAnalytics());
    try {
      final result = await Future.wait([
        _analyticsRepository.getDashboardAnalytics(),
        _analyticsRepository.getToppers(),
      ]);
      final dashboardAnalytics =
          result[0] as Either<Failure, DashboardAnalytics?>;
      final leaderboardAnalytics =
          result[1] as Either<Failure, List<LeaderboardModel>?>;
      dashboardAnalytics.fold(
        (failure) => emit(DashboardAnalyticsFetchedFailed(failure)),
        (dashboardAnalytics) {
          List<LeaderboardModel>? leaderboard;
          leaderboardAnalytics.fold(
            (failure) => emit(DashboardAnalyticsFetchedFailed(failure)),
            (leaderboardAnalytics) {
              leaderboard = leaderboardAnalytics;
            },
          );
          emit(
            DashboardAnalyticsFetched(
              dashboardAnalytics: dashboardAnalytics!,
              leaderboardData: leaderboard!,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("error while fetching attempted tests $e");
    }
  }
}
