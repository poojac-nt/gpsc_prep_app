import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

import '../../core/di/di.dart';
import '../../core/error/failure.dart';

class TestRepository {
  final SupabaseHelper _supabase;
  TestRepository(this._supabase);

  Future<Either<Failure, List<DailyTestModel>>> fetchDailyTest() async =>
      await _supabase.fetchDailyTests();
}
