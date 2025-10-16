// study_material_event.dart

abstract class StudyMaterialEvent {}

class LoadStudyMaterials extends StudyMaterialEvent {}

class AddStudyMaterial extends StudyMaterialEvent {
  final String title;
  final String url;
  final String language;
  final int? testId;

  AddStudyMaterial({
    required this.title,
    required this.url,
    required this.language,
    this.testId,
  });
}

class FetchTestWithoutMaterial extends StudyMaterialEvent {
  FetchTestWithoutMaterial();
}
