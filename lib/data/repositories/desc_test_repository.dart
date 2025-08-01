import 'package:either_dart/either.dart';

import '../../core/error/failure.dart';
import '../../core/helpers/supabase_helper.dart';
import '../../domain/entities/daily_test_model.dart';

class DescTestRepository {
  final SupabaseHelper _supabaseHelper;
  DescTestRepository(this._supabaseHelper);
  Future<Either<Failure, List<DailyTestModel>>> fetchDailyDescTest() async =>
      await _supabaseHelper.fetchDescriptiveTests();
}
