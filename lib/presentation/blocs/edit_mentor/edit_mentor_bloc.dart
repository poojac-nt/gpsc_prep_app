import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';

part 'edit_mentor_event.dart';
part 'edit_mentor_state.dart';

class EditMentorBloc extends Bloc<EditMentorEvent, EditMentorState> {
  final MentorRepository _mentorRepository;

  EditMentorBloc(this._mentorRepository) : super(EditMentorInitial()) {
    on<UpdateMentor>(_onUpdateMentor);
    on<DeleteMentor>(_onDeleteMentor);
    on<FetchSubjects>(_onFetchSubjects);
  }

  Future<void> _onFetchSubjects(
    FetchSubjects event,
    Emitter<EditMentorState> emit,
  ) async {
    emit(SubjectsLoading());
    final result = await _mentorRepository.fetchSubjects();
    result.fold(
      (failure) => emit(SubjectsError(failure.message)),
      (subjects) => emit(SubjectsLoaded(subjects)),
    );
  }

  Future<void> _onUpdateMentor(
    UpdateMentor event,
    Emitter<EditMentorState> emit,
  ) async {
    emit(MentorSaving());
    final result = await _mentorRepository.updateMentor(
      userId: event.userId,
      name: event.name,
      bio: event.bio,
      subjectExpertise: event.subjectExpertise,
      isActive: event.isActive,
      profileImage: event.profileImage,
    );
    result.fold(
      (failure) => emit(MentorOperationError(failure.message)),
      (mentor) => emit(MentorUpdateSuccess(mentor)),
    );
  }

  Future<void> _onDeleteMentor(
    DeleteMentor event,
    Emitter<EditMentorState> emit,
  ) async {
    emit(MentorSaving());
    final result = await _mentorRepository.deleteMentor(event.userId);
    result.fold(
      (failure) => emit(MentorOperationError(failure.message)),
      (_) => emit(MentorDeleteSuccess()),
    );
  }
}
