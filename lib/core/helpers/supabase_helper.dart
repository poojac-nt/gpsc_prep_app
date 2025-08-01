import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/constants/secrets.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'log_helper.dart';

class SupabaseHelper {
  final supabase = Supabase.instance.client;
  final LogHelper _log;
  final SnackBarHelper _snackBar;
  final CacheManager _cache;

  SupabaseHelper(this._log, this._snackBar, this._cache);

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
      _snackBar.showSuccess('Logged In as ${user.name}');
      return Right(user);
    } catch (e, s) {
      _snackBar.showError('Please Check Your Login Credentials');
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
        _snackBar.showError('A user with this email already exists.');
        return Left(Failure('A user with this email already exists.'));
      }

      final signUpResponse = await supabase.auth.signUp(
        password: data.password!,
        email: data.email,
      );
      final user = signUpResponse.user;

      if (user == null) {
        _snackBar.showError('User SignUp Failed');
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
      _snackBar.showSuccess('User Created Successfully as ${data.name}');
      final userModel = UserModel.fromJson(insertResponse);
      return Right(userModel);
    } catch (e) {
      _snackBar.showError('Error Creating New User: $e');
      _log.e('[createUser] Error: $e');
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
      _log.i('[Update User] Updated User: ${updatedUser.toJson()}');
      _snackBar.showSuccess(
        'User Information Updated Successfully as ${updatedUser.name}',
      );
      return Right(updatedUser);
    } catch (e) {
      _snackBar.showError('Error Updating User Info: ${e.toString()}');
      _log.e('[Update User] Error: $e', error: e);
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
      _snackBar.showSuccess('User deleted successfully');
      supabase.auth.signOut();
      return true;
    } catch (e) {
      _snackBar.showError('Error deleting user: ${e.toString()}');
      _log.e('Error in deleteUser: $e');
      return false;
    }
  }

  Future<Either<Failure, List<QuestionModel>>> fetchMCQTestQuestions(
    int testId,
  ) async {
    try {
      final List<Map<String, dynamic>> response = await supabase.rpc(
        SupabaseKeys.getTestQuestionsByTestId,
        params: {'p_test_id': testId},
      );

      _log.i(response.toString());

      final questions =
          response
              .where((e) => e != null)
              .map((e) => QuestionModel.fromJson(e))
              .toList();

      _log.i(questions.toString());

      return Right(questions);
    } catch (e, stackTrace) {
      _snackBar.showError('Error fetching test questions: ${e.toString()}');
      _log.e(
        "Fetch Error: $e"
        "\nStackTrace: $stackTrace",
      );
      return Left(Failure(e.toString()));
    }
  }

  ///Insert Daily Tests Results
  Future<Either<Failure, List<DailyTestModel>>> fetchDailyMcqTests() async {
    try {
      final response = await supabase
          .from(SupabaseKeys.testsTable)
          .select()
          .filter('test_type', 'in', '(dtmcq,mcq)')
          .order('id', ascending: false);

      var result = response.map((e) => DailyTestModel.fromJson(e)).toList();

      _log.i('Total test : ${result.length}');
      return Right(result);
    } catch (e, s) {
      _snackBar.showError('Error fetching tests: ${e.toString()}');
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching test : ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<TestResultModel>>> insertDailyMcqTestsResults(
    TestResultModel test,
  ) async {
    try {
      // Step 1: Check if result already exists for this user and test
      final existingResult =
          await supabase
              .from(SupabaseKeys.testResultsTable)
              .select()
              .eq('user_id', test.userId)
              .eq('test_id', test.testId)
              .maybeSingle(); // returns null if not found

      if (existingResult != null) {
        // Step 2: Delete existing result
        final deleteResponse = await supabase
            .from(SupabaseKeys.testResultsTable)
            .delete()
            .eq('user_id', test.userId)
            .eq('test_id', test.testId);

        _log.i('Existing test result deleted: $deleteResponse');
      }

      // Step 3: Insert the new result
      final response =
          await supabase
              .from(SupabaseKeys.testResultsTable)
              .insert({
                'user_id': test.userId,
                'test_id': test.testId,
                'total_questions': test.totalQuestions,
                'correct_answers': test.correctAnswers,
                'incorrect_answers': test.inCorrectAnswers,
                'attempted_questions': test.attemptedQuestions,
                'not_attempted_questions': test.notAttemptedQuestions,
                'score': test.score,
                'time_taken': test.timeTaken,
              })
              .select()
              .single(); // returns single inserted row

      _log.i('Test result inserted successfully: $response');

      final model = TestResultModel.fromJson(response);
      _snackBar.showSuccess('Test Result Inserted Successfully');
      return Right([model]);
    } catch (e) {
      _snackBar.showError('Error inserting test result: ${e.toString()}');
      _log.e('Error inserting/fetching test result: $e');
      return Left(Failure("Error inserting test: ${e.toString()}"));
    }
  }

  ///Fetch Daily Test Results
  Future<Either<Failure, TestResultModel?>> fetchResultForSingleMcqTest({
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
      _log.i("Result ${response.toString()}");
      return Right(model);
    } catch (e) {
      _snackBar.showError('Error fetching result: $e');
      return Left(Failure("Error fetching result: ${e.toString()}"));
    }
  }

  Future<void> updateOrInsertFcmToken(String fcmToken) async {
    try {
      final userId = supabase.auth.currentSession?.user.id;

      if (userId != null) {
        final response =
            await supabase
                .from(SupabaseKeys.usersTable)
                .update({SupabaseKeys.fcmToken: fcmToken})
                .eq(SupabaseKeys.authId, userId)
                .select()
                .single();
        _log.i('FCM token upsert response: $response');
      } else {
        _log.e('No authenticated user found.');
      }
    } catch (e) {
      _log.e('Exception in updateOrInsertFcmToken: $e');
    }
  }

  Future<AppVersionStatus> appVersionCheck() async {
    try {
      // Get current app version string (e.g., "1.0.0")
      final info = await PackageInfo.fromPlatform();
      final currentVersionStr = info.version;
      final currentVersion = Version.parse(currentVersionStr);
      _log.i('Current app version: $currentVersion');

      // Determine platform-specific key
      final platformKey =
          Platform.isAndroid
              ? 'min_android_version'
              : Platform.isIOS
              ? 'min_ios_version'
              : null;

      if (platformKey == null) {
        _log.e('Unsupported platform for version check.');
        _snackBar.showError('Unsupported platform for version check.');
        return AppVersionStatus.upToDate;
      }

      // Fetch version requirement from Supabase
      final response =
          await supabase
              .from(SupabaseKeys.config)
              .select()
              .eq("key", platformKey)
              .single();

      _log.i('Config response: $response');
      if (response.isEmpty) {
        _snackBar.showError('🚫 No config entry found for "$platformKey"');
        _log.e('🚫 No config entry found for "$platformKey"');
        return AppVersionStatus.upToDate; // Fail open
      }

      final value = response["value"] as String?;
      if (value == null || value.isEmpty) {
        _snackBar.showError(
          '⚠️ Empty or missing version string for "$platformKey"',
        );
        _log.e('⚠️ Empty or missing version string for "$platformKey"');
        return AppVersionStatus.upToDate;
      }

      Version requiredVersion;
      try {
        requiredVersion = Version.parse(value);
      } catch (e) {
        _snackBar.showError('⚠️ Invalid version format in config: "$value"');
        _log.e('⚠️ Invalid version format in config: "$value"');
        return AppVersionStatus.upToDate;
      }

      // Compare versions
      if (currentVersion < requiredVersion) {
        return AppVersionStatus.needsUpdate;
      }

      return AppVersionStatus.upToDate;
    } catch (e) {
      _log.e('❌ Error in appVersionCheck: $e');
      return AppVersionStatus.needsUpdate;
    }
  }

  Future<Either<Failure, List<DailyTestModel>>> fetchDescriptiveTests() async {
    try {
      final response = await supabase
          .from(SupabaseKeys.testsTable)
          .select()
          .filter('test_type', 'eq', 'desc')
          .order('id', ascending: false);
      final result = response.map((e) => DailyTestModel.fromJson(e)).toList();
      _log.i('Total test : ${result.length}');
      return Right(result);
    } catch (e) {
      _log.e('Error in fetching test: $e');
      return Left(Failure("Error in Fetching test"));
    }
  }
}
