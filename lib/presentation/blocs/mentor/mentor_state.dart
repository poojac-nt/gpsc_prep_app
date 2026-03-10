import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';

abstract class MentorState {}

class MentorInitial extends MentorState {}

class MentorListLoading extends MentorState {}

class MentorListLoaded extends MentorState {
  final List<MentorModel> mentors;
  MentorListLoaded(this.mentors);
}

class MentorListError extends MentorState {
  final String message;
  MentorListError(this.message);
}
