// study_material_state.dart

import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/study_material_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';

abstract class StudyMaterialState {}

class StudyMaterialInitial extends StudyMaterialState {}

class StudyMaterialLoading extends StudyMaterialState {}

class StudyMaterialLoaded extends StudyMaterialState {
  final List<StudyMaterialModel> materials;

  StudyMaterialLoaded(this.materials);
}

class TestWithoutMaterialLoaded extends StudyMaterialState {
  final List<TestWithoutMaterial> tests;

  TestWithoutMaterialLoaded(this.tests);
}

class StudyMaterialError extends StudyMaterialState {
  final Failure failure;

  StudyMaterialError(this.failure);
}

class StudyMaterialAdded extends StudyMaterialState {
  StudyMaterialAdded();
}
