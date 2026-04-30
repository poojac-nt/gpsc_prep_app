import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final AnalyticsRepository _analyticsRepository;

  LeaderboardBloc(this._analyticsRepository) : super(LeaderboardInitial()) {
    on<FetchLeaderboardData>(_onFetchLeaderboardData);
  }

  Future<void> _onFetchLeaderboardData(
    FetchLeaderboardData event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    final result = await _analyticsRepository.getTop3Scorers();
    result.fold(
      (failure) => emit(LeaderboardError(failure)),
      (data) => emit(LeaderboardLoaded(data)),
    );
  }
}
