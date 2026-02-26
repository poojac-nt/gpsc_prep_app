import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/subject_repository.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository _subjectRepository;

  SubjectBloc(this._subjectRepository) : super(SubjectInitial()) {
    on<FetchSubjects>(_onFetchSubjects);
  }

  Future<void> _onFetchSubjects(
    FetchSubjects event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());
    final result = await _subjectRepository.fetchSubjects();
    result.fold(
      (failure) => emit(SubjectFailure(failure.message)),
      (subjects) => emit(SubjectSuccess(subjects)),
    );
  }
}
