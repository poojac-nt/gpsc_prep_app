import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';

class CourseRepository {
  final SupabaseHelper _supabaseHelper;

  CourseRepository(this._supabaseHelper);

  Future<Either<Failure, CoursePayload>> createCourse(
    CoursePayload payload,
  ) async {
    return await _supabaseHelper.createCourses(payload);
  }

  Future<Either<Failure, List<CourseModel>>> fetchCourses() async {
    return await _supabaseHelper.fetchCourses();
  }
}
