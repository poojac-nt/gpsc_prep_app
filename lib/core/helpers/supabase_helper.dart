import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_payload.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/domain/entities/admin_stats_model.dart';
import 'package:gpsc_prep_app/domain/entities/attempted_question_stats_model.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/dashboard_analytics.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_assignment_list_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_dashbord_data.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_test_submissions.dart';
import 'package:gpsc_prep_app/domain/entities/option_matrix_model.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/domain/entities/package_model.dart';
import 'package:gpsc_prep_app/domain/entities/peer_review_model.dart';
import 'package:gpsc_prep_app/domain/entities/pending_submission.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/student_list_with_mentor.dart';
import 'package:gpsc_prep_app/domain/entities/subject_model.dart';
import 'package:gpsc_prep_app/domain/entities/submission_report_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_without_material_model.dart';
import 'package:gpsc_prep_app/domain/entities/trend_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';
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

  late final userId = _cache.user!.id;

  /// ===========================================================================
  /// AUTHENTICATION
  /// ===========================================================================

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

  Future<bool> checkUserExist(String email) async {
    final response = await supabase.rpc(
      SupabaseKeys.checkUserExist,
      params: {"user_email": email},
    );
    return response;
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
  Future<Either<Failure, UserModel>> createStudent(UserPayload data) async {
    try {
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
              .select()
              .single();
      _log.i('[UserCreated] Response: $insertResponse');
      _snackBar.showSuccess('User Created Successfully as ${data.name}');
      final userModel = UserModel.fromJson(insertResponse);
      return Right(userModel);
    } catch (e) {
      _snackBar.showError('Error Creating New Student: $e');
      _log.e('[createStudent] Error: $e');
      return Left(Failure('Error Creating Student: $e'));
    }
  }

  Future<Either<Failure, MentorModel>> createMentorByAdmin(
    UserPayload data,
  ) async {
    try {
      if (data.subjectExpertise == null || data.subjectExpertise!.isEmpty) {
        _log.e('Mentor creation failed: No subjects provided');
        return Left(Failure('Mentor must have at least one subject'));
      }

      final response = await supabase.functions.invoke(
        'create-mentor',
        body: {
          'full_name': data.name,
          'email': data.email,
          'bio': data.bio,
          'subject_expertise': data.subjectExpertise,
          'password': data.password,
        },
      );

      if (response.status >= 400) {
        final errorData = response.data;
        return Left(
          Failure(
            errorData is Map
                ? errorData['error'] ?? 'Error creating mentor'
                : errorData.toString(),
          ),
        );
      }

      // ✅ Properly cast the response
      final result = response.data as Map<String, dynamic>;
      final userModel = UserModel.fromJson(
        result['user'] as Map<String, dynamic>,
      );

      final subjects =
          (result['subjects'] as List<dynamic>)
              .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
              .toList();

      return Right(MentorModel(user: userModel, subjects: subjects));
    } catch (e, st) {
      _log.e('Exception in createMentorByAdmin: $e\n$st', error: e);
      return Left(Failure('Error Creating Mentor: $e'));
    }
  }

  Future<void> requestResetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: "starics://password-reset",
    );
  }

  Future<void> resetPassword(String password) async {
    supabase.auth.updateUser(UserAttributes(password: password));
  }

  /// ===========================================================================
  /// USER MANAGEMENT
  /// ===========================================================================

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

  Future<bool> deleteUser() async {
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
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

  /// ===========================================================================
  /// Subjects
  /// ===========================================================================

  Future<Either<Failure, List<SubjectModel>>> fetchSubjects() async {
    try {
      final result = await supabase.from(SupabaseKeys.subjects).select('*');
      final subjects =
          (result as List).map((e) => SubjectModel.fromJson(e)).toList();
      return Right(subjects);
    } catch (e) {
      _snackBar.showError('Error Fetching Subjects: ${e.toString()}');
      _log.e('Error Fetching Subjects: $e', error: e);
      return Left(Failure('Error Fetching Subjects: ${e.toString()}'));
    }
  }

  /// ===========================================================================
  /// COURSES
  /// ===========================================================================

  Future<Either<Failure, CourseModel>> createCourses(CoursePayload data) async {
    try {
      final jsonData = data.toJson();

      final result =
          await supabase
              .from(SupabaseKeys.courseTable)
              .insert(jsonData)
              .select()
              .single();
      final course = CourseModel.fromJson(result);
      return Right(course);
    } catch (e) {
      _snackBar.showError('Error Creating Course: ${e.toString()}');
      _log.e('[Create Course] Error: $e', error: e);
      return Left(Failure('Error Creating Course: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<CourseModel>>> fetchCourses() async {
    try {
      final rpcResponse = await supabase.rpc(SupabaseKeys.getCoursesWithTests);

      final List<dynamic> courseList = rpcResponse as List;

      final courses = courseList.map((e) => CourseModel.fromJson(e)).toList();

      return Right(courses);
    } catch (e) {
      _snackBar.showError('Error fetching courses: ${e.toString()}');
      _log.e('[Fetch Courses] Error: $e', error: e);
      return Left(Failure('Error fetching courses: ${e.toString()}'));
    }
  }

  /// ===========================================================================
  /// TESTS (MCQ)
  /// ===========================================================================

  Future<Either<Failure, List<QuestionModel>>> fetchMCQTestQuestions(
    int testId,
  ) async {
    try {
      final List<Map<String, dynamic>> response = await supabase.rpc(
        SupabaseKeys.getTestQuestionsByTestId,
        params: {'p_test_id': testId},
      );

      _log.i("Questions Fetched for the testId $testId: ${response.length}");

      final questions = response.map((e) => QuestionModel.fromJson(e)).toList();
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

  Future<Either<Failure, List<TestModel>>> fetchDailyMcqTests({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await supabase
          .from(SupabaseKeys.testsTable)
          .select()
          .inFilter('test_type', ['dtmcq', 'mcq'])
          .lte('available_at', DateTime.now().toUtc().toIso8601String())
          .order('available_at', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final result = response.map((e) => TestModel.fromJson(e)).toList();

      _log.i('Fetched tests: ${result.length} (offset: $offset)');
      return Right(result);
    } catch (e, s) {
      _snackBar.showError('Error fetching tests: ${e.toString()}');
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching test : ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<TestModel>>> fetchPrelimsTests() async {
    try {
      final response = await supabase
          .from(SupabaseKeys.testsTable)
          .select()
          .inFilter('test_type', ['prelims'])
          .isFilter('course_id', null)
          .lte('available_at', DateTime.now().toUtc().toIso8601String())
          .order('available_at', ascending: false);

      final result = response.map((e) => TestModel.fromJson(e)).toList();

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

  Future<Either<Failure, TestResultWithTopScoreModel>>
  submitTestResultWithDetails({
    required TestResultModel test,
    required List<DetailedTestResult> detailedResults,
  }) async {
    try {
      final payload =
          detailedResults
              .map(
                (e) => {
                  'question_id': e.questionId,
                  'is_correct': e.isCorrect,
                  'selected_option': e.selectedOption,
                  'time_spent': e.timeSpent,
                },
              )
              .toList();

      final response = await supabase.rpc(
        SupabaseKeys.submitTestAttempt,
        params: {
          'p_user_id': test.userId,
          'p_test_id': test.testId,
          'p_score': test.score,
          'p_correct_answers': test.correctAnswers,
          'p_incorrect_answers': test.inCorrectAnswers,
          'p_attempted_questions': test.attemptedQuestions,
          'p_not_attempted_questions': test.notAttemptedQuestions,
          'p_time_taken': test.timeTaken,
          'p_total_questions': test.totalQuestions,
          'p_details': payload,
        },
      );

      _log.i('RPC response: $response');

      // Cast response to Map<String, dynamic>
      final data = response as Map<String, dynamic>;
      final model = TestResultWithTopScoreModel.fromJson(data);

      _snackBar.showSuccess('Test Result Submitted Successfully');

      return Right(model);
    } catch (e) {
      _snackBar.showError('Error submitting test result: ${e.toString()}');
      _log.e('Error submitting test result: $e');
      return Left(Failure("RPC submit failed: ${e.toString()}"));
    }
  }

  Future<Either<Failure, TestResultModel?>> fetchResultForSingleMcqTest({
    required int testId,
  }) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.testResultsTable)
              .select()
              .eq('user_id', userId!)
              .eq('test_id', testId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle(); // now safe even if 2 rows exist in DB

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

  Future<Either<Failure, TestResultWithTopScoreModel?>>
  getUserTestResultWithTopScore({required int testId}) async {
    try {
      final response = await supabase.rpc(
        SupabaseKeys.getTestAttemptWithAnalytics,
        params: {'p_user_id': userId, 'p_test_id': testId},
      );

      // Cast response to Map<String, dynamic>
      final data = response as Map<String, dynamic>;
      final model = TestResultWithTopScoreModel.fromJson(data);

      _log.i("Result with top score: ${response.toString()}");
      return Right(model);
    } catch (e) {
      _snackBar.showError('Error fetching result with Top score: $e');
      return Left(
        Failure("Error fetching result with Top Score: ${e.toString()}"),
      );
    }
  }

  Future<Either<Failure, List<TestResultModel>>> fetchAllTestResults() async {
    try {
      final response = await supabase
          .from('test_results')
          .select()
          .eq('user_id', userId!);

      final results =
          (response as List).map((e) => TestResultModel.fromJson(e)).toList();

      return Right(results);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, TestModel>> fetchSingleTestFromId(int testId) async {
    try {
      final response =
          await supabase
              .from(SupabaseKeys.testsTable)
              .select()
              .eq('id', testId)
              .single();

      var result = TestModel.fromJson(response);

      _log.i('Link test : $result');
      return Right(result);
    } catch (e, s) {
      _snackBar.showError('Error fetching tests: ${e.toString()}');
      _log.e('Error in fetching test: $e', s: s);
      return Left(Failure("Error fetching test : ${e.toString()}"));
    }
  }

  /// ===========================================================================
  /// TESTS (DESCRIPTIVE)
  /// ===========================================================================

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

  Future<Either<Failure, List<DescTestModel>>> fetchDescriptiveTests({
    int? courseId,
  }) async {
    try {
      final query = supabase.from(SupabaseKeys.descTests).select();

      if (courseId != null) {
        query.eq('course_id', courseId);
      } else {
        query.isFilter('course_id', null);
      }

      final response = await query.order('id', ascending: false);
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
      final formattedAnswers =
          answers.entries
              .map((e) => {'question_id': e.key, 'answer': e.value})
              .toList();
      await supabase.rpc(
        SupabaseKeys.submitDescTest,
        params: {
          'p_user_id': userId,
          'p_test_id': testId,
          'p_answers': formattedAnswers,
        },
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

  Future<Either<Failure, void>> submitDescriptiveTestPdf({
    required int testId,
    required File file,
  }) async {
    try {
      // 1. Upload the PDF
      final fileName =
          "${testId}_${_cache.getUserId()}_${DateTime.now().millisecondsSinceEpoch}";
      final filePath = "answers/$fileName";

      await supabase.storage.from(SupabaseKeys.answers).upload(filePath, file);

      final publicUrl = supabase.storage
          .from(SupabaseKeys.answers)
          .getPublicUrl(filePath);

      // 2. Insert into des_test_submission table
      await supabase.from(SupabaseKeys.descTestSubmissions).insert({
        'user_id': userId,
        'test_id': testId,
        'submission_pdf_url': publicUrl,
        'is_finalized': true,
      });

      return const Right(null);
    } catch (e) {
      _log.e("Failed to submit descriptive test PDF: $e");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<int>>> fetchDescriptiveTestSubmissions() async {
    try {
      if (userId == null) {
        return Left(Failure("User not found"));
      }
      final response = await supabase
          .from(SupabaseKeys.descTestSubmissions)
          .select('test_id')
          .eq('user_id', userId!);

      final List<int> ids =
          (response as List).map((e) => e['test_id'] as int).toList();
      return Right(ids);
    } catch (e) {
      _log.e("Failed to fetch descriptive test submissions: $e");
      return Left(Failure(e.toString()));
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
          .eq('user_id', userId!);

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

  /// ===========================================================================
  /// TEST PROGRESS
  /// ===========================================================================

  Future<Either<Failure, void>> updateUserTestStatus({
    required int testId,
    required String status,
  }) async {
    try {
      assert(status == 'in_progress' || status == 'paused');

      // Check if row already exists
      final existing =
          await supabase
              .from(SupabaseKeys.userTests)
              .select('id, started_at')
              .eq('user_id', userId!)
              .eq('test_id', testId)
              .maybeSingle();

      if (existing == null) {
        // 🔹 First start
        await supabase.from(SupabaseKeys.userTests).insert({
          'user_id': userId!,
          'test_id': testId,
          'status': status,
          'started_at': DateTime.now().toUtc().toIso8601String(),
          'last_reminder_sent_at': null,
        });
      } else {
        // 🔹 Pause / Resume
        final updatePayload = {
          'status': status,
          if (status == 'paused') 'last_reminder_sent_at': null,
        };

        await supabase
            .from(SupabaseKeys.userTests)
            .update(updatePayload)
            .eq('user_id', userId!)
            .eq('test_id', testId);
      }

      _log.i('User test updated: test=$testId status=$status');
      return const Right(null);
    } catch (e) {
      _snackBar.showError('Error updating test status');
      _log.e('Error updating user test: $e');
      return Left(
        Failure('Error inserting or updating user test: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> deleteUserTest({required int testId}) async {
    try {
      await supabase
          .from(SupabaseKeys.userTests)
          .delete()
          .eq('user_id', userId!)
          .eq('test_id', testId);

      _log.i('User test progress deleted: test=$testId');
      return const Right(null);
    } catch (e) {
      _log.e('Error deleting user test progress: $e');
      return Left(Failure('Error deleting user test: ${e.toString()}'));
    }
  }

  Future<Either<Failure, TestAttemptState>> fetchTestAttemptState(
    int testId,
  ) async {
    try {
      final response = await supabase.rpc(
        SupabaseKeys.getTestAttemptState,
        params: {'p_user_id': userId!, 'p_test_id': testId},
      );

      final results = TestAttemptState.fromJson(response);
      _log.i('Fetched TestAttemptState: $results');
      return Right(results);
    } catch (e) {
      _log.e('Error fetching TestAttemptState: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// ===========================================================================
  /// ANALYTICS & REPORTS
  /// ===========================================================================

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
        return Left(Failure("No one has attempted this question"));
      }
    } catch (e) {
      _log.e('Error fetching question correctness for test ID $testId: $e');
      return Left(Failure("Failed to fetch data for test ID $testId"));
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

  Future<Either<Failure, List<AttemptedQuestionStat>>>
  fetchAttemptedQuestionStats(int testId) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getAttemptedQuestionStats,
        params: {'p_test_id': testId},
      );

      final stats = AttemptedQuestionStat.fromRpcResponse(result);

      _log.i("Attempted Question Stats length: ${stats.first.attemptedCount}");

      return Right(stats);
    } catch (e, st) {
      _log.e("Error fetching attempted question stats", error: e, s: st);
      return Left(Failure("Error fetching attempted question stats"));
    }
  }

  Future<Either<Failure, OverAllAnalyticsModel>> fetchOverAllAnalytics({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final params = <String, dynamic>{'p_user_id': userId};

      if (from != null && to != null) {
        params['p_from'] = from.toUtc().toIso8601String();
        params['p_to'] = to.toUtc().toIso8601String();
      }

      final result = await supabase.rpc(
        SupabaseKeys.getOverAllAnalytics,
        params: params,
      );
      _log.i(
        "Overall Analytics fetched successfully for date range.from $from to $to",
      );
      return Right(OverAllAnalyticsModel.fromJson(result));
    } catch (e) {
      _log.e("Error fetching Overall analytics", error: e);
      return Left(Failure('Error fetching Overall analytics'));
    }
  }

  Future<Either<Failure, TrendResultModel>> fetchTrendForUser() async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getAccuracyTrend,
        params: {'p_user_id': userId},
      );

      final stats = TrendResultModel.fromRpcResponse(result);

      _log.i(
        "Weekly: ${stats.weekly.length}, Monthly: ${stats.monthly.length}",
      );

      return Right(stats);
    } catch (e) {
      _log.e("Error fetching Accuracy Trend", error: e);
      return Left(Failure("Error fetching Accuracy Trend"));
    }
  }

  Future<Either<Failure, DashboardAnalytics>> getDashboardAnalytics() async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getDashboardAnalytics,
        params: {'p_user_id': userId},
      );
      final analytics = DashboardAnalytics.fromJson(
        result.first as Map<String, dynamic>,
      );
      _log.i("Dashboard Analytics: $analytics");
      return Right(analytics);
    } catch (e, st) {
      _log.e("Error fetching dashboard analytics", error: e, s: st);
      return Left(Failure("Error fetching dashboard analytics"));
    }
  }

  Future<Either<Failure, List<LeaderboardModel>>> getPrelimsTopper() async {
    try {
      final result = await supabase.rpc(SupabaseKeys.getPrelimsTopper);

      final toppers =
          (result as List)
              .map((e) => LeaderboardModel.fromJson(e as Map<String, dynamic>))
              .toList();

      _log.i("Leader Analytics: $toppers");
      return Right(toppers);
    } catch (e, st) {
      _log.e("Error fetching leaderboard analytics", error: e, s: st);
      return Left(Failure("Error fetching leaderboard analytics"));
    }
  }

  /// ===========================================================================
  /// STUDY MATERIALS
  /// ===========================================================================

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

  ///===========================================================================
  /// APP CONFIGURATION
  /// ===========================================================================
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

  /// ===========================================================================
  /// Peer Review
  /// ===========================================================================

  Future<Either<Failure, List<PeerReviewModel>>> peerReview({
    required int testId,
    required int questionId,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.peerReview,
        params: {'p_test_id': testId, 'p_question_id': questionId},
      );
      final reviews =
          (result as List)
              .map((e) => PeerReviewModel.fromJson(e as Map<String, dynamic>))
              .toList();
      _log.i(
        "Peer Review fetched successfully for testId $testId and questionId $questionId",
      );
      // debugPrint("Peer Review Result: ${reviews.first.latestComment}");
      return Right(reviews);
    } catch (e) {
      _log.e(
        "Error fetching Peer Review for testId $testId and questionId $questionId: $e",
      );
      return Left(
        Failure(
          "Error fetching Peer Review for testId $testId and questionId $questionId: ${e.toString()}",
        ),
      );
    }
  }

  Future<Either<Failure, DetailedPeerReviewModel>> detailedPeerReview({
    required int answerId,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.detailedPeerReviewPerUser,
        params: {'p_answer_id': answerId},
      );
      final list = result as List<dynamic>;
      if (list.isEmpty) {
        return Left(Failure('No answer found for answerId $answerId'));
      }
      final reviews = DetailedPeerReviewModel.fromJson(
        list.first as Map<String, dynamic>,
      );
      _log.i(
        "Detailed Peer Review fetched successfully for answerId $answerId",
      );
      return Right(reviews);
    } catch (e) {
      _log.e("Error fetching Detailed Peer Review for answerId $answerId: $e");
      return Left(
        Failure(
          "Error fetching Detailed Peer Review for answerId $answerId: ${e.toString()}",
        ),
      );
    }
  }

  Future<Either<Failure, Comment>> insertPeerReview({
    required int answerId,
    required int reviewerId,
    required String comment,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.insertPeerReview,
        params: {
          'p_answer_id': answerId,
          'p_reviewer_id': reviewerId,
          'p_comment': comment,
        },
      );
      final commentJson = (result as List).first as Map<String, dynamic>;
      final commentModel = Comment.fromJson(commentJson);
      _log.i(
        "Peer Review comment inserted successfully for answerId $answerId by reviewerId $reviewerId",
      );

      return Right(commentModel);
    } catch (e) {
      _log.e(
        "Error inserting Peer Review comment for answerId $answerId by reviewerId $reviewerId: $e",
      );
      return Left(
        Failure(
          "Error inserting Peer Review comment for answerId $answerId by reviewerId $reviewerId: ${e.toString()}",
        ),
      );
    }
  }

  /// ===========================================================================
  /// Package Management (for in-app purchases, if needed in future)
  /// ===========================================================================

  Future<Either<Failure, List<PackageModel>>> fetchPackages() async {
    try {
      final result = await supabase.from(SupabaseKeys.package).select('*');
      final packages =
          (result as List).map((e) => PackageModel.fromJson(e)).toList();
      return Right(packages);
    } catch (e) {
      _snackBar.showError('Error Fetching Packages: ${e.toString()}');
      _log.e('Error Fetching Packages: $e', error: e);
      return Left(Failure('Error Fetching Packages: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<UserPurchaseModel>>> fetchUserPurchase() async {
    try {
      final result = await supabase
          .from(SupabaseKeys.userPurchase)
          .select('*')
          .eq('user_id', userId!);
      final purchase =
          (result as List).map((e) => UserPurchaseModel.fromJson(e)).toList();
      return Right(purchase);
    } catch (e) {
      _snackBar.showError('Error Fetching Packages: ${e.toString()}');
      _log.e('Error Fetching Packages: $e', error: e);
      return Left(Failure('Error Fetching Packages: ${e.toString()}'));
    }
  }

  Future<Either<Failure, UserPurchaseModel>> purchaseCourse({
    required UserPurchasePayload payload,
  }) async {
    try {
      final result =
          await supabase
              .from(SupabaseKeys.userPurchase)
              .insert({
                'user_id': userId,
                'course_id': payload.courseId,
                'assessment_type': payload.assessmentType.name,
              })
              .select()
              .single();
      final purchase = UserPurchaseModel.fromJson(result);
      return Right(purchase);
    } catch (e) {
      _snackBar.showError('Error Purchasing Course: ${e.toString()}');
      _log.e('Error Purchasing Course :$e', error: e);
      return Left(Failure('Error Purchasing Course: ${e.toString()}'));
    }
  }

  /// ===========================================================================
  /// Mentor Assign Flows
  /// ===========================================================================

  Future<Either<Failure, List<PendingSubmission>>>
  fetchPendingSubmission() async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getTestWithUnassignedSubmission,
      );
      final submissions =
          (result as List)
              .map(
                (e) => PendingSubmission.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
      return Right(submissions);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Pending Submission Test: ${e.toString()}',
      );
      _log.e('Error Fetching Pending Submission Test:$e', error: e);
      return Left(
        Failure('Error Fetching Pending Submission Test: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<StudentListWithMentor>>>
  fetchTestWisePendingSubmission({required int testId}) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getUnassignedStudentsForTest,
        params: {'p_test_id': testId},
      );
      final submissions =
          (result as List)
              .map(
                (e) => StudentListWithMentor.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
      return Right(submissions);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Test Wise Pending Submission: ${e.toString()}',
      );
      _log.e('Error Fetching Test Wise Pending Submission:$e', error: e);
      return Left(
        Failure('Error Fetching Test Wise Pending Submission: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> assignMentorToTest({
    required List<MentorAssignmentPayload> payloads,
  }) async {
    try {
      await supabase.rpc(
        SupabaseKeys.rpcDescMentorAssignment,
        params: {'p_rows': payloads.map((e) => e.toJson()).toList()},
      );

      return const Right(null);
    } catch (e) {
      _snackBar.showError('Error Assigning Mentors: ${e.toString()}');
      _log.e('Error Assigning Mentors:$e', error: e);
      return Left(Failure('Error Assigning Mentors: ${e.toString()}'));
    }
  }

  /// ===========================================================================
  /// Mentor Profile Data
  /// ===========================================================================
  Future<Either<Failure, MentorDashboardData>>
  fetchMentorDashboardData() async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.mentorDashboard,
        params: {'p_mentor_id': userId},
      );

      final data = (result as List).first as Map<String, dynamic>;

      final dashboardData = MentorDashboardData.fromJson(data);

      return Right(dashboardData);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Mentor Dashboard Data: ${e.toString()}',
      );
      _log.e('Error Fetching Mentor Dashboard Data:$e', error: e);

      return Left(
        Failure('Error Fetching Mentor Dashboard Data: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<MentorAssignmentListModel>>>
  fetchMentorSubmission() async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.mentorSubmission,
        params: {'p_mentor_id': userId},
      );
      final data =
          (result as List)
              .map(
                (e) => MentorAssignmentListModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();

      return Right(data);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Mentor Submission List: ${e.toString()}',
      );
      _log.e('Error Fetching Mentor Submission List:$e', error: e);
      return Left(
        Failure('Error Fetching Mentor Submission List: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, List<MentorTestSubmissions>>>
  fetchMentorTestSubmission({required int testId}) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.fetchMentorTestSubmissions,
        params: {'p_mentor_id': userId, 'p_test_id': testId},
      );
      final data =
          (result as List)
              .map(
                (e) => MentorTestSubmissions.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();

      return Right(data);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Mentor Test Submission List for $testId: ${e.toString()}',
      );
      _log.e(
        'Error Fetching Mentor Test Submission List for $testId $e',
        error: e,
      );
      return Left(
        Failure(
          'Error Fetching Mentor Test Submission List for $testId ${e.toString()}',
        ),
      );
    }
  }

  Future<Either<Failure, void>> submitMentorEvaluation({
    required int submissionId,
    required Map<String, dynamic> questionScores,
    String? feedback,
    File? evaluatedPdfFile,
  }) async {
    try {
      String? publicUrl;

      if (evaluatedPdfFile != null) {
        final fileName =
            "${submissionId}_${userId}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final filePath = "reviewed_pdf/$fileName";

        await supabase.storage
            .from(SupabaseKeys.mentorReview)
            .upload(filePath, evaluatedPdfFile);

        publicUrl = supabase.storage
            .from(SupabaseKeys.mentorReview)
            .getPublicUrl(filePath);
      }

      await supabase.rpc(
        SupabaseKeys.submitMentorEvaluation,
        params: {
          'p_submission_id': submissionId,
          'p_marks_per_question': questionScores,
          'p_reviewed_pdf_link': publicUrl,
          'p_feedback': feedback,
        },
      );

      return const Right(null);
    } catch (e) {
      _snackBar.showError('Error submitting evaluation: ${e.toString()}');
      _log.e('Error submitting evaluation: $e', error: e);
      return Left(Failure('Error submitting evaluation: ${e.toString()}'));
    }
  }

  Future<Either<Failure, SubmissionReportModel>> fetchSubmissionReport({
    required int submissionId,
  }) async {
    try {
      final result = await supabase.rpc(
        SupabaseKeys.getSubmissionsReport,
        params: {'p_submission_id': submissionId},
      );

      final Map<String, dynamic> jsonData;
      if (result is List && result.isNotEmpty) {
        jsonData = result.first as Map<String, dynamic>;
      } else if (result is Map<String, dynamic>) {
        jsonData = result;
      } else {
        throw Exception('Invalid response format or empty data');
      }

      final data = SubmissionReportModel.fromJson(jsonData);

      return Right(data);
    } catch (e) {
      _snackBar.showError(
        'Error Fetching Submission Report for  $submissionId: ${e.toString()}',
      );
      _log.e(
        'Error Fetching Submission Report for  $submissionId: $e',
        error: e,
      );
      return Left(
        Failure(
          'Error Fetching Submission Report for  $submissionId: ${e.toString()}',
        ),
      );
    }
  }

  /// ===========================================================================
  /// Admin Profile Data
  /// ===========================================================================
  Future<Either<Failure, AdminStatsModel>> fetchAdminStats() async {
    try {
      final response = await supabase.rpc(SupabaseKeys.getAdminDashboardStats);
      final data = AdminStatsModel.fromJson(response);
      return Right(data);
    } catch (e) {
      _log.e('Error fetching admin stats:$e', error: e);
      return Left(Failure("Error fetching admin stats: ${e.toString()}"));
    }
  }

  Future<Either<Failure, List<MentorModel>>> fetchMentorList() async {
    try {
      final response = await supabase.rpc(SupabaseKeys.getMentorList);

      final mentors =
          (response as List).map((e) => MentorModel.fromJson(e)).toList();
      _log.i('Fetched ${mentors.length} mentors');
      return Right(mentors);
    } catch (e) {
      _log.e('Error fetching mentor list: $e', error: e);
      return Left(Failure('Error fetching mentor list: ${e.toString()}'));
    }
  }

  Future<Either<Failure, MentorModel>> updateMentorInfo({
    required int userId,
    required String name,
    required String bio,
    required List<int> subjectExpertise,
    required bool isActive,
    File? profileImage,
  }) async {
    try {
      String? profilePictureUrl;

      // 1️⃣ Upload profile image if provided
      if (profileImage != null) {
        final fileName =
            'mentor_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'uploads/$fileName';

        await supabase.storage
            .from(SupabaseKeys.profilePicture)
            .upload(
              filePath,
              profileImage,
              fileOptions: const FileOptions(upsert: true),
            );

        profilePictureUrl = supabase.storage
            .from(SupabaseKeys.profilePicture)
            .getPublicUrl(filePath);
      }

      // 2️⃣ Call RPC to update mentor
      final response = await supabase.rpc(
        'update_mentor_details',
        params: {
          'p_user_id': userId,
          'p_name': name,
          'p_bio': bio,
          'p_subject_ids': subjectExpertise,
          'p_is_active': isActive,
          'p_profile_picture': profilePictureUrl,
        },
      );

      if (response == null || response['success'] != true) {
        return Left(Failure(response?['message'] ?? 'Failed to update mentor'));
      }

      // 3️⃣ Fetch updated mentor data
      final mentorList = await supabase.rpc(SupabaseKeys.getMentorList);

      final mentorJson = (mentorList as List).firstWhere(
        (e) => e['user_data']['id'] == userId,
      );

      final mentor = MentorModel.fromJson(mentorJson);

      _snackBar.showSuccess('Mentor profile updated successfully');
      _log.i('Mentor updated: ${mentor.user.name}');

      return Right(mentor);
    } catch (e, stack) {
      _snackBar.showError('Error updating mentor: ${e.toString()}');
      _log.e('Error updating mentor: $e', error: e, s: stack);

      return Left(Failure('Error updating mentor: ${e.toString()}'));
    }
  }

  Future<Either<Failure, void>> deleteMentorAccount(int userId) async {
    try {
      await supabase.from(SupabaseKeys.usersTable).delete().eq('id', userId);
      _snackBar.showSuccess('Mentor account deleted');
      _log.i('Mentor account deleted: userId=$userId');
      return const Right(null);
    } catch (e) {
      _snackBar.showError('Error deleting mentor: ${e.toString()}');
      _log.e('Error deleting mentor: $e', error: e);
      return Left(Failure('Error deleting mentor: ${e.toString()}'));
    }
  }
}
