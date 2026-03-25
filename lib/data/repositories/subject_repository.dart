import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';

import '../../core/error/failure.dart';

class SubjectRepository {
  final SupabaseHelper _supabase;

  SubjectRepository(this._supabase);

  Future<Either<Failure, List<SubjectModel>>> fetchSubjects() async =>
      await _supabase.fetchSubjects();
}
