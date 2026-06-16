import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';

import '../../domain/entities/product_model.dart';

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

  Future<Either<Failure, CourseModel>> fetchCourseWithTests(
    int courseId,
  ) async {
    return await _supabaseHelper.fetchCourseWithTests(courseId: courseId);
  }

  Future<Either<Failure, void>> toggleCourseActive({
    required int courseId,
    required bool isActive,
  }) async {
    return await _supabaseHelper.toggleCourseActive(
      courseId: courseId,
      isActive: isActive,
    );
  }

  Future<Either<Failure, List<ProductModel>>> fetchProducts() async {
    return await _supabaseHelper.fetchProducts();
  }
}
