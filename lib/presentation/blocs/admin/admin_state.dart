part of 'admin_bloc.dart';

@immutable
abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminStatsLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final AdminStatsModel stats;

  AdminStatsLoaded(this.stats);
}

class AdminStatsError extends AdminState {
  final String message;

  AdminStatsError(this.message);
}
