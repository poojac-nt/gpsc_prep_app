// study_material_event.dart

import 'package:gpsc_prep_app/utils/enums/language_enum.dart';

abstract class StudyMaterialEvent {}

class LoadStudyMaterials extends StudyMaterialEvent {}

class UploadStudyMaterial extends StudyMaterialEvent {
  final String title;
  final String url;
  final String language;
  final int? testId;

  UploadStudyMaterial({
    required this.title,
    required this.url,
    required this.language,
    this.testId,
  });
}

class UploadStudyMaterialWithTest extends StudyMaterialEvent {
  final String title;
  final String url;
  final String language;
  final List<Map<String, dynamic>> payload;

  UploadStudyMaterialWithTest({
    required this.title,
    required this.url,
    required this.language,
    required this.payload,
  });
}

class FetchTestWithoutMaterial extends StudyMaterialEvent {
  final LanguageEnum language;

  FetchTestWithoutMaterial({required this.language});
}

class FetchStudyMaterial extends StudyMaterialEvent {
  FetchStudyMaterial();
}

class ClearTestWithoutMaterial extends StudyMaterialEvent {}
