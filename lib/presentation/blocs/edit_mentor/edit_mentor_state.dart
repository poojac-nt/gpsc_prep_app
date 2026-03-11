part of 'edit_mentor_bloc.dart';

abstract class EditMentorState {}

class EditMentorInitial extends EditMentorState {}

class SubjectsLoading extends EditMentorState {}

class SubjectsLoaded extends EditMentorState {
  final List<SubjectModel> subjects;

  SubjectsLoaded(this.subjects);
}

class SubjectsError extends EditMentorState {
  final String message;

  SubjectsError(this.message);
}

class MentorSaving extends EditMentorState {}

class MentorUpdateSuccess extends EditMentorState {
  final MentorModel mentor;

  MentorUpdateSuccess(this.mentor);
}

class MentorDeleteSuccess extends EditMentorState {}

class MentorOperationError extends EditMentorState {
  final String message;

  MentorOperationError(this.message);
}
