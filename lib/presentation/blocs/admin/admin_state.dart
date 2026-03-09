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

class MentorListLoading extends AdminState {}

class MentorListLoaded extends AdminState {
  final List<MentorModel> mentors;
  MentorListLoaded(this.mentors);
}

class MentorListError extends AdminState {
  final String message;
  MentorListError(this.message);
}

class MentorSaving extends AdminState {}

class MentorUpdateSuccess extends AdminState {
  final UserModel mentor;
  MentorUpdateSuccess(this.mentor);
}

class MentorDeleteSuccess extends AdminState {}

class MentorOperationError extends AdminState {
  final String message;
  MentorOperationError(this.message);
}
