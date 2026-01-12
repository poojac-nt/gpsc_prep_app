import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc_state.dart';

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
      final result = await _analyticsRepository.getDashboardAnalytics();
      result.fold(
        (failure) {
          emit(DashboardAnalyticsFetchedFailed(failure));
        },
        (dashboardAnalytics) {
          emit(
            DashboardAnalyticsFetched(dashboardAnalytics: dashboardAnalytics),
          );
        },
      );
    } catch (e) {
      debugPrint("error while fetching attempted tests $e");
    }
  }
}
