import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/question_model.dart';

class TestRepository {
  final SupabaseHelper _supabase;

  TestRepository(this._supabase);

  Future<Either<Failure, List<DailyTestModel>>> fetchDailyTest() async =>
      await _supabase.fetchDailyMcqTests();

  Future<Either<Failure, List<QuestionModel>>> fetchMcqTestQuestions(
    int testID,
  ) async => await _supabase.fetchMCQTestQuestions(testID);

  Future<Either<Failure, List<DescQuestionModel>>> fetchDescTestQuestions(
    int testID,
  ) async => await _supabase.fetchDescTestQuestions(testID);

  Future<Either<Failure, List<TestResultModel>>> insertTestResult(
    TestResultModel testResult,
  ) async => await _supabase.insertDailyMcqTestsResults(testResult);

  Future<Either<Failure, TestResultModel?>> singleTestResult(
    int testId,
  ) async => await _supabase.fetchResultForSingleMcqTest(testId: testId);

  Future<Either<Failure, List<DescTestModel>>> fetchDailyDescTest() async =>
      await _supabase.fetchDescriptiveTests();

  Future<Either<Failure, List<DescAnswerModel>>> fetchAnswersForTest(
    int testId,
    int userId,
  ) async => await _supabase.fetchAnswersForTest(testId, userId);

  Future<Either<Failure, Map<String, dynamic>>>
  fetchAllAttemptedTests() async => await _supabase.fetchAttemptedAllTests();

  Future<Either<Failure, DailyTestModel>> fetchSingleTestFromId(
    int testId,
  ) async => await _supabase.fetchSingleTestFromId(testId);

  Future<Either<Failure, DescTestModel>> fetchSingleDescTestFromId(
    int testId,
  ) async => await _supabase.fetchSingleDescTestFromId(testId);

  Future<Either<Failure, void>> submitDescriptiveTest(
    int testId,
    Map<int, dynamic> answers,
  ) async => await _supabase.submitDescriptiveTest(testId, answers);

  Future<Either<Failure, List<String>>> uploadPdfAnswer(
    int testId,
    int questionId,
    List<File> files,
  ) async => await _supabase.uploadPdfAnswer(
    testId: testId,
    files: files,
    questionId: questionId,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>>
  fetchQuestionCorrectnessCounts(int testId) async {
    return await _supabase.fetchTestQuestionCorrectness(testId);
  }
}
