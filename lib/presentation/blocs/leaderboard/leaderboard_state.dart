import 'package:gpsc_prep_app/domain/entities/leaderboard_screen_model.dart';
import '../../../core/error/failure.dart';

abstract class LeaderboardState {
  const LeaderboardState();
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardScreenModel leaderboardData;

  const LeaderboardLoaded(this.leaderboardData);
}

class LeaderboardError extends LeaderboardState {
  final Failure failure;

  const LeaderboardError(this.failure);
}
