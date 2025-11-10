import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/study_material_model.dart';

class StudyMaterialRepository {
  final SupabaseHelper _supabase;

  StudyMaterialRepository(this._supabase);

  Future<Either<Failure, List<TestWithoutMaterial>>>
  fetchTestsWithoutStudyMaterial({required String language}) async =>
      await _supabase.fetchTestsWithoutStudyMaterial(language: language);

  Future<Either<Failure, void>> insertStudyMaterial(
    String title,
    String link,
    String language,
    int? testId,
  ) async => await _supabase.insertStudyMaterial(
    title: title,
    link: link,
    language: language,
    testId: testId,
  );

  Future<Either<Failure, void>> insertStudyMaterialWithTest(
    String title,
    String link,
    String language,
    final List<Map<String, dynamic>> payload,
  ) async => await _supabase.insertStudyMaterialWithTest(
    title: title,
    link: link,
    language: language,
    payload: payload,
  );

  Future<Either<Failure, List<StudyMaterialModel>>>
  fetchAllStudyMaterials() async => await _supabase.fetchAllStudyMaterials();
}
