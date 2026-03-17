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
    on<FetchSubjects>(_onFetchSubjects);
    on<FetchMentorByUserId>(_onFetchMentorByUserId);
  }

  Future<void> _onFetchMentorByUserId(
    FetchMentorByUserId event,
    Emitter<EditMentorState> emit,
  ) async {
    emit(MentorDetailLoading());
    final result = await _mentorRepository.getMentorByUserId(event.userId);
    result.fold(
      (failure) => emit(MentorOperationError(failure.message)),
      (mentor) => emit(MentorDetailLoaded(mentor)),
    );
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
}
