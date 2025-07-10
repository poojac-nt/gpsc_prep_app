import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/question_model.dart';

class TestRepository {
  final SupabaseHelper _supabase;

  TestRepository(this._supabase);

  Future<Either<Failure, List<DailyTestModel>>> fetchDailyTest() async =>
      await _supabase.fetchDailyTests();

  Future<Either<Failure, List<QuestionModel>>> fetchTestQuestions(
    int testID,
  ) async => await _supabase.fetchTestQuestions(testID);

  Future<Either<Failure, List<TestResultModel>>> insertTestResult(
    TestResultModel testResult,
  ) async => await _supabase.insertDailyTestsResults(testResult);
}
