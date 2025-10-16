// study_material_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/study_material_repository.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';

import 'study_material_event.dart';
import 'study_material_state.dart';

class StudyMaterialBloc extends Bloc<StudyMaterialEvent, StudyMaterialState> {
  final StudyMaterialRepository _studyMaterialRepository;

  StudyMaterialBloc(this._studyMaterialRepository)
    : super(StudyMaterialInitial()) {
    on<FetchTestWithoutMaterial>(_fetchTestWithoutMaterials);
    on<AddStudyMaterial>(_addStudyMaterial);
  }

  Future<void> _fetchTestWithoutMaterials(
    FetchTestWithoutMaterial event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final result =
          await _studyMaterialRepository.fetchTestsWithoutStudyMaterial();

      result.fold((failure) => emit(StudyMaterialError(failure)), (
        List<TestWithoutMaterial> list,
      ) {
        emit(TestWithoutMaterialLoaded(list));
      });
    } catch (e) {
      emit(StudyMaterialError(Failure(e.toString())));
    }
  }

  Future<void> _addStudyMaterial(
    AddStudyMaterial event,
    Emitter<StudyMaterialState> emit,
  ) async {
    emit(StudyMaterialLoading());
    try {
      final result = await _studyMaterialRepository.insertStudyMaterial(
        event.title,
        event.url,
        event.language,
        event.testId,
      );

      result.fold(
        (failure) => emit(StudyMaterialError(failure)),
        (_) => emit(StudyMaterialAdded()),
      );
    } catch (e) {
      emit(StudyMaterialError(Failure(e.toString())));
    }
  }
}
