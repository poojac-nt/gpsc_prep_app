import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';

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
