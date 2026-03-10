import 'package:gpsc_prep_app/domain/entities/admin_stats_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';

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
