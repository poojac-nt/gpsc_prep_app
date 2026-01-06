import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:gpsc_prep_app/utils/enums/language_enum.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/study_material_model.dart';
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
                'role': UserRole.student.role,
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
  Future<bool> deleteUser() async {
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      final userId = session?.user.id;
      if (session == null) {
        throw Exception("User not logged in");
      }
      final response = await supabase.functions.invoke(
        'delete_user',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.status == 200) {
        _snackBar.showSuccess("User deleted successfully");
        return true;
      }
      throw Exception(response.data['error']);
    } catch (e) {
      _log.e("Delete user error: $e");
      _snackBar.showError("Error deleting user");
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

      final questions = response.map((e) => QuestionModel.fromJson(e)).toList();

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

  Future<Either<Failure, List<DescQuestionModel>>> fetchDescTestQuestions(
    int testId,
  ) async {
    try {
      final List<Map<String, dynamic>> response = await supabase.rpc(
        SupabaseKeys.getDescTestQuestionsByTestId,
        params: {'p_desc_test_id': testId},
      );

      _log.i(response.toString());

      final questions =
          response.map((e) => DescQuestionModel.fromJson(e)).toList();

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

  Future<Either<Failure, List<TestResultModel>>> fetchAllTestResults() async {
    try {
      final response = await supabase
          .from('test_results')
          .select()
          .eq('user_id', _cache.user!.id!);

      final results =
          (response as List).map((e) => TestResultModel.fromJson(e)).toList();

      return Right(results);
    } catch (e) {
      return Left(Failure(e.toString()));
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
                .select();
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
      _cache.setAppVersion(currentVersionStr);
      _log.i('Current app version: $currentVersionStr');

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

      final requiredVersionStr = response["value"] as String?;
      if (requiredVersionStr == null || requiredVersionStr.isEmpty) {
        _snackBar.showError(
          '⚠️ Empty or missing version string for "$platformKey"',
        );
        _log.e('⚠️ Empty or missing version string for "$platformKey"');
        return AppVersionStatus.upToDate;
      }

      _log.i('Required version: $requiredVersionStr');

      // Compare versions using semantic versioning
      final currentVersion = Version.parse(currentVersionStr);
      final requiredVersion = Version.parse(requiredVersionStr);

      if (currentVersion < requiredVersion) {
        _log.w('App needs update: $currentVersionStr < $requiredVersionStr');
        return AppVersionStatus.needsUpdate;
      }

      return AppVersionStatus.upToDate;
    } catch (e) {
      _log.e('❌ Error in appVersionCheck: $e');
      return AppVersionStatus.upToDate; // Changed to fail open for better UX
    }
  }

  Future<Either<Failure, List<DescTestModel>>> fetchDescriptiveTests() async {
    try {
      final response = await supabase
          .from(SupabaseKeys.descTests)
          .select()
          .order('id', ascending: false);
      final result = response.map((e) => DescTestModel.fromJson(e)).toList();
      if (result.isEmpty) {
        _log.w('No descriptive tests found');
        return Right([]);
      }
      return Right(result);
    } catch (e) {
      _log.e('Error in fetching test: $e');
      return Left(Failure("Error in Fetching test"));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> fetchAttemptedAllTests() async {
    try {
      final response = await supabase.rpc(
        SupabaseKeys.getAttemptedTestStats,
        params: {'user_id': _cache.user!.id},
      );

      final data = response as Map<String, dynamic>;
      final attemptedTests = data['attempted_tests'];
      final averageScore = data['average_score'];

      _log.i('Attempted Tests: $attemptedTests Average Score: $averageScore');

      return Right({
        'attempted_tests': attemptedTests,
        'average_score': averageScore.toDouble(),
      });
    } catch (e) {
      _log.e('Error in fetching attempted tests: $e');
      return Left(Failure("Error in fetching attempted tests"));
    }
  }

  Future<Either<Failure, DailyTestModel>> fetchSingleTestFromId(
    int testId,
  ) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.testsTable)
              .select()
              .eq('id', testId)
              .single();

      var result = DailyTestModel.fromJson(response);

      _log.i('Link test : $result');
      return Right(result);
    } catch (e, s) {
      _snackBar.showError('Error fetching tests: ${e.toString()}');
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching test : ${e.toString()}"));
    }
  }

  Future<Either<Failure, DescTestModel>> fetchSingleDescTestFromId(
    int testId,
  ) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.descTests)
              .select()
              .eq('id', testId)
              .single();

      var result = DescTestModel.fromJson(response);
      return Right(result);
    } catch (e, s) {
      _snackBar.showError('Error fetching desc tests: ${e.toString()}');
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching desc test : ${e.toString()}"));
    }
  }

  Future<Either<Failure, String>> submitDescriptiveTest(
    int testId,
    Map<int, dynamic> answers,
  ) async {
    try {
      await supabase
          .from(SupabaseKeys.descTestResult)
          .upsert(
            answers.entries.map((e) {
              return {
                'user_id': _cache.user!.id,
                'test_id': testId,
                'question_id': e.key,
                'answer': e.value, // could be text or pdf url
              };
            }).toList(),
          );

      return Right("Test submitted successfully!");
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> uploadPdfAnswer({
    required int testId,
    required int questionId,
    required List<File> files,
  }) async {
    try {
      List<String> publicUrls = [];

      for (var file in files) {
        final fileName =
            "${testId}_${questionId}_${_cache.getUserId()}_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
        final filePath = "answers/$fileName";

        await supabase.storage
            .from(SupabaseKeys.answers)
            .upload(filePath, file);

        final publicUrl = supabase.storage
            .from(SupabaseKeys.answers)
            .getPublicUrl(filePath);
        publicUrls.add(publicUrl);

        _log.i(
          "File uploaded successfully for Question Id $questionId: $publicUrl",
        );
      }

      return Right(publicUrls);
    } catch (e) {
      _log.e("File upload failed: $e");
      return Left(Failure("File upload failed: ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<DescAnswerModel>>> fetchAnswersForTest(
    int testId,
  ) async {
    try {
      final response = await supabase
          .from('desc_test_detailed_results')
          .select()
          .eq('test_id', testId)
          .eq('user_id', _cache.user!.id!);

      final answers =
          (response as List<dynamic>)
              .map(
                (row) => DescAnswerModel.fromJson(row as Map<String, dynamic>),
              )
              .toList();

      return Right(answers);
    } catch (e) {
      return Left(Failure('Error fetching answers: $e'));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>>
  fetchTestQuestionCorrectness(int testId) async {
    try {
      final response = await supabase.rpc(
        SupabaseKeys.getQuestionCorrectnessCounts,
        params: {'test_id': testId},
      );

      final resultData = response;

      if (resultData is List && resultData.isNotEmpty) {
        final List<Map<String, dynamic>> data =
            resultData.map((item) => Map<String, dynamic>.from(item)).toList();

        _log.i(
          'Fetched ${data.length} question correctness rows for testId: $testId',
        );

        return Right(data);
      } else {
        _log.w('No question correctness data found for test ID: $testId');
        return Left(Failure("No data found for test ID $testId"));
      }
    } catch (e) {
      _log.e('Error fetching question correctness for test ID $testId: $e');
      return Left(Failure("Failed to fetch data for test ID $testId"));
    }
  }

  Future<Either<Failure, void>> insertTestDetailedResult({
    required DetailedTestResult detailedTestResult,
  }) async {
    try {
      final result = await supabase
          .from(SupabaseKeys.testDetailedResults)
          .upsert({
            'user_id': detailedTestResult.userId,
            'test_id': detailedTestResult.testId,
            'question_id': detailedTestResult.questionId,
            'is_correct': detailedTestResult.isCorrect,
            'selected_option': detailedTestResult.selectedOption,
          });

      _log.i('Inserted test detailed result: $result');
      return const Right(null);
    } catch (e) {
      _log.e('Error inserting test detailed result: $e');
      return Left(Failure("Error inserting test detailed result"));
    }
  }

  Future<Either<Failure, List<OptionMatrixModel>>> fetchOptionMatrixForTest({
    required int testId,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getOptionMatrixForTest,
        params: {'p_test_id': testId},
      );

      final List<OptionMatrixModel> optionMatrix =
          (result as List<dynamic>)
              .map(
                (e) => OptionMatrixModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();

      _log.i(
        'Fetched option matrix for test $testId: ${optionMatrix.length} entries',
      );
      return Right(optionMatrix);
    } catch (e) {
      _log.e('Error fetching option matrix for test $testId : $e');

      return Left(Failure('Error fetching option matrix for test $testId'));
    }
  }

  Future<Either<Failure, List<TestWithoutMaterial>>>
  fetchTestsWithoutStudyMaterial({required LanguageEnum language}) async {
    try {
      // Call the Supabase RPC function
      final response = await supabase.rpc(
        SupabaseKeys.getTestWithoutStudyMaterialForLanguage,
        params: {'lang': language.name}, // Use .name to get 'en', 'hi', or 'gj'
      );

      if (response is List && response.isNotEmpty) {
        // Convert each item (Map) into a TestWithoutMaterial model
        final tests =
            response
                .map(
                  (item) => TestWithoutMaterial.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList();

        _log.i(
          'Fetched ${tests.length} tests without study materials for language ${language.language}.', // Use .language to get full name
        );

        return Right(tests);
      } else {
        _log.w('No unlinked tests found.');
        return Left(
          Failure("No unlinked tests found for language ${language.language}"),
        );
      }
    } catch (e) {
      _log.e(
        'Error fetching unlinked tests for language ${language.language}: $e',
      );
      return Left(
        Failure(
          "Failed to fetch unlinked tests for language ${language.language}",
        ),
      );
    }
  }

  Future<Either<Failure, void>> insertStudyMaterial({
    required String title,
    required String link,
    required String language,
    int? testId,
  }) async {
    try {
      final result = await supabase
          .from(
            SupabaseKeys.studyMaterial,
          ) // <-- make sure this matches your table name
          .upsert({
            'title': title,
            'link': link,
            'test_id': testId,
            'language': language,
          });

      _log.i('Inserted study material: $result');
      return const Right(null);
    } catch (e) {
      _log.e('Error inserting study material: $e');
      return Left(Failure("Error inserting study material"));
    }
  }

  Future<Either<Failure, void>> insertStudyMaterialWithTest({
    required String title,
    required String link,
    required String language,
    required List<Map<String, dynamic>> payload,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.insertTestWithStudyMaterial,
        params: {
          'payload': payload,
          'study_title': title,
          'study_link': link,
          'study_language': language,
        },
      );

      _log.i('Inserted study material with test: $result');
      return const Right(null);
    } catch (e) {
      _log.e('Error inserting study material with test: $e');
      return Left(Failure("Error inserting study material with test"));
    }
  }

  Future<Either<Failure, List<StudyMaterialModel>>>
  fetchAllStudyMaterials() async {
    try {
      final result = await supabase
          .from(SupabaseKeys.studyMaterial)
          .select()
          .order('created_at', ascending: false);

      final materials =
          result.map((e) => StudyMaterialModel.fromJson(e)).toList();

      _log.i("Materials length:${materials.length}");
      return Right(materials);
    } catch (e) {
      _log.e("Error fetching study material: $e");
      return Left(Failure("Error fetching study materials"));
    }
  }

  Future<void> requestResetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: "starics://password-reset",
    );
  }

  Future<bool> checkUserExist(String email) async {
    final response = await supabase.rpc(
      SupabaseKeys.checkUserExist,
      params: {"user_email": email},
    );
    return response;
  }

  Future<void> resetPassword(String password) async {
    supabase.auth.updateUser(UserAttributes(password: password));
  }
}
