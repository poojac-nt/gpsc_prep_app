import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/constants/secrets.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'log_helper.dart';

class SupabaseHelper {
  final supabase = Supabase.instance.client;
  final LogHelper _log;
  final CacheManager _cache = getIt<CacheManager>();

  SupabaseHelper(this._log);

  Future<bool> doesUserExist(String email) async {
    final response = await supabase
        .from(SupabaseKeys.usersTable)
        .select()
        .eq(SupabaseKeys.email, email);
    if (response.isEmpty) {
      return false;
    }
    return true;
  }

  ///Login Method
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _log.i('[login] Auth response: $response');
      final userId = response.user?.id;
      if (userId == null) {
        return Left(Failure('User ID not found after login.'));
      }

      final userResponse =
          await supabase
              .from(SupabaseKeys.usersTable)
              .select()
              .eq(SupabaseKeys.authId, userId)
              .single();
      _log.i('[login] User table response: $userResponse');
      final user = UserModel.fromJson(userResponse);
      return Right(user);
    } catch (e, s) {
      _log.e('[login] Error occurred', error: e, s: s);
      return Left(Failure('Incorrect Username or Password.'));
    }
  }

  ///New User Create Method

  Future<Either<Failure, UserModel>> createUser(UserPayload data) async {
    try {
      final jsonData = data.toJson();
      _log.d('[insertUser] Payload: $jsonData');
      final existingUser =
          await supabase
              .from(SupabaseKeys.usersTable)
              .select('user_email')
              .eq('user_email', data.email)
              .maybeSingle();

      if (existingUser != null) {
        _log.w('Email already exists: ${data.email}');
        return Left(Failure('A user with this email already exists.'));
      }

      final signUpResponse = await supabase.auth.signUp(
        password: data.password!,
        email: data.email,
      );
      final user = signUpResponse.user;

      if (user == null) {
        _log.e('User SignUp Failed');
      }
      final userId = user?.id;
      _log.d("User id: $userId");
      final insertResponse =
          await supabase
              .from(SupabaseKeys.usersTable)
              .insert({
                'full_name': data.name,
                'address': data.address,
                'number': data.number,
                'role': 'Student',
                'user_email': data.email,
                'auth_id': userId,
                'profile_picture': data.profilePicture,
              })
              .select('*')
              .single();
      _log.i('[UserCreated] Response: $insertResponse');
      final userModel = UserModel.fromJson(insertResponse);
      return Right(userModel);
    } catch (e) {
      return Left(Failure('Error Creating New User $e'));
    }
  }

  ///Update User Information Method

  Future<Either<Failure, UserModel>> updateUserInfo(UserPayload data) async {
    try {
      final jsonData = data.toJson();
      _log.d('[Update User] Payload: $jsonData');

      await supabase.rpc(
        SupabaseKeys.updateUserInfo,
        params: {
          'p_auth_id': data.authID,
          'p_full_name': data.name,
          'p_email': data.email,
          'p_address': data.address,
          'p_number': data.number,
          'p_profile_picture': data.profilePicture,
        },
      );

      // ✅ Recommended: refetch updated user
      final userResponse =
          await supabase
              .from('users')
              .select()
              .eq('auth_id', data.authID!)
              .single();

      final updatedUser = UserModel.fromJson(userResponse);
      return Right(updatedUser);
    } catch (e) {
      return Left(Failure('Error Updating User Info: ${e.toString()}'));
    }
  }

  ///Delete User from both public and auth tables
  Future<bool> deleteUser(String userId) async {
    try {
      // Delete from auth.users
      final supabaseAdmin = SupabaseClient(
        AppSecrets.apiUrl,
        AppSecrets.serviceKey,
      );
      await supabaseAdmin.auth.admin.deleteUser(userId);

      // Delete from public.users
      await supabase
          .from(SupabaseKeys.usersTable)
          .delete()
          .eq('auth_id', userId);

      _log.i('User deleted successfully from both public.users and auth.users');
      supabase.auth.signOut();
      return true;
    } catch (e) {
      _log.e('Error in deleteUser: $e');
      return false;
    }
  }

  Future<Either<Failure, List<QuestionModel>>> fetchTestQuestions(
    int testId,
  ) async {
    try {
      final data = await supabase
          .from(SupabaseKeys.testQuestionTable)
          .select('questions(*)')
          .eq('test_id', testId);
      _log.i("Data: ${data.toString()}");

      final questions =
          data
              .where((e) => e['questions'] != null) // Safety check
              .map((e) => QuestionModel.fromJson(e['questions']))
              .where((q) => q.questionEn != null) // Ensure only valid entries
              .toList();
      _log.i("Fetched questions: ${questions.length}");
      Future.delayed(Duration(seconds: 30));
      return Right(questions);
    } catch (e, stackTrace) {
      print("Fetch Error: $e");
      print("StackTrace: $stackTrace");
      return Left(Failure(e.toString()));
    }
  }

  ///Insert Daily Tests Results
  Future<Either<Failure, List<DailyTestModel>>> fetchDailyTests() async {
    try {
      final response = await supabase
          .from(SupabaseKeys.testsTable)
          .select()
          .order('id', ascending: false);

      var result = response.map((e) => DailyTestModel.fromJson(e)).toList();

      _log.i('Total test : ${result.length}');
      return Right(result);
    } catch (e, s) {
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching test : ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<TestResultModel>>> insertDailyTestsResults(
    TestResultModel test,
  ) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.testResultsTable)
              .insert({
                'user_id': test.userId,
                'test_id': test.testId,
                'correct_answers': test.correctAnswers,
                'incorrect_answers': test.inCorrectAnswers,
                'attempted_questions': test.attemptedQuestions,
                'not_attempted_questions': test.notAttemptedQuestions,
                'total_marks': test.totalMarks,
                'time_taken': test.timeTaken,
              })
              .select()
              .single(); // returns single inserted row

      _log.i('Test result inserted successfully: $response');

      final model = TestResultModel.fromJson(response);
      return Right([model]);
    } catch (e) {
      _log.e('Error inserting/fetching test result: $e');
      return Left(Failure("Error inserting test: ${e.toString()}"));
    }
  }

  ///Fetch Daily Test Results
  Future<Either<Failure, TestResultModel?>> fetchResultForSingleTest({
    required int testId,
  }) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.testResultsTable)
              .select()
              .eq('user_id', _cache.user!.id!)
              .eq('test_id', testId)
              .maybeSingle(); // Use maybeSingle for optional single result

      if (response == null) {
        return Right(null); // No result yet
      }

      final model = TestResultModel.fromJson(response);
      return Right(model);
    } catch (e) {
      return Left(Failure("Error fetching result: ${e.toString()}"));
    }
  }
}
