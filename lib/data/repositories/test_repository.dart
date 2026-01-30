import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/question_model.dart';

class TestRepository {
  final SupabaseHelper _supabase;

  TestRepository(this._supabase);

  Future<Either<Failure, List<TestModel>>> fetchDailyTest() async =>
      await _supabase.fetchDailyMcqTests();

  Future<Either<Failure, List<QuestionModel>>> fetchMcqTestQuestions(
    int testID,
  ) async => await _supabase.fetchMCQTestQuestions(testID);

  Future<Either<Failure, List<DescQuestionModel>>> fetchDescTestQuestions(
    int testID,
  ) async => await _supabase.fetchDescTestQuestions(testID);

  Future<Either<Failure, TestResultModel>> submitTestResultWithDetails(
    TestResultModel testResult,
    List<DetailedTestResult> detailedResults,
  ) async => await _supabase.submitTestResultWithDetails(
    test: testResult,
    detailedResults: detailedResults,
  );

  Future<Either<Failure, TestResultWithTopScoreModel?>>
  getUserTestResultWithTopScore(int testId) async =>
      await _supabase.getUserTestResultWithTopScore(testId: testId);

  Future<Either<Failure, List<TestReviewByDifficulty>>> fetchUserTestReview(
    int testId,
  ) async => await _supabase.fetchUserTestReview(testId: testId);

  Future<Either<Failure, List<TestResultModel>>> fetchAllTestResults() async =>
      await _supabase.fetchAllTestResults();

  Future<Either<Failure, TestAttemptState>> fetchTestAttemptState(
    int testId,
  ) async => await _supabase.fetchTestAttemptState(testId);

  Future<Either<Failure, List<DescTestModel>>> fetchDailyDescTest() async =>
      await _supabase.fetchDescriptiveTests();

  Future<Either<Failure, List<DescAnswerModel>>> fetchAnswersForTest(
    int testId,
  ) async => await _supabase.fetchAnswersForTest(testId);

  Future<Either<Failure, TestModel>> fetchSingleTestFromId(int testId) async =>
      await _supabase.fetchSingleTestFromId(testId);

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

  Future<Either<Failure, List<OptionMatrixModel>>> optionMatrixForQuestion({
    required int testId,
  }) {
    return _supabase.fetchOptionMatrixForTest(testId: testId);
  }

  Future<Either<Failure, List<TestModel>>> fetchPrelimsTests() async =>
      await _supabase.fetchPrelimsTests();
}
