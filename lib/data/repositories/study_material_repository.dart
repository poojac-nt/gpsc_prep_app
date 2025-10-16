import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';

import '../../core/error/failure.dart';

class StudyMaterialRepository {
  final SupabaseHelper _supabase;

  StudyMaterialRepository(this._supabase);

  Future<Either<Failure, List<TestWithoutMaterial>>>
  fetchTestsWithoutStudyMaterial() async =>
      await _supabase.fetchTestsWithoutStudyMaterial();

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
}
