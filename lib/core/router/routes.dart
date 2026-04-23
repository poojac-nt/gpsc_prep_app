import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/all_test/all_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/analytics_screen/all_difficulty_analytics_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/analytics_screen/all_question_types_analytics_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/analytics_screen/all_subjects_analytics_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/analytics_screen/analytics_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/mentor_registration_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/request_reset_password_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/reset_password_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/add_product_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/admin_dashboard_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/all_test_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/notifications/create_notification_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/edit_mentor_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/mentor_assign_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/admin/mentor_list_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor/all_assigned_tests_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor/free_test_review_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor/test_students_list_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor_dashborad_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/student_dashboard_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/desc_full_questions_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_answer_detail_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_answers_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_test_result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/mentor_evaluation_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/peer_review_answer_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/student_evaluation_result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/error_screen/error_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/paid_courses/assessment_type_selection_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/paid_courses/course_details_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/paid_courses/course_list_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/prelims/omr_answer_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/prelims/prelims_mcq_instruction_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/preview_screen/questions_preview_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/registration_screen/registration_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/splash_screen/splash_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/admin/upload_study_material_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/student/language_selection_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/student/student_study_material_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_instruction_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/add_course_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/desc_review_questions_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/mcq_review_question_upload_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../data/repositories/test_repository.dart';
import '../../presentation/screens/dashboard/admin/assign_mentor_detail_screen.dart';
import '../../presentation/screens/descriptive_test_module/answer_writing_screen.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test_instruction_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/test/mcq_test_screen.dart';
import '../../utils/enums/user_role.dart';
import '../cache_manager.dart';
import '../../domain/entities/notification_model.dart';
import '../../presentation/screens/dashboard/admin/notifications/notification_history_screen.dart';

final List<GoRoute> appRoutes = [
  // Handle /openMaterial?id=21&language=en links
  GoRoute(
    path: '/openMaterial',
    builder: (context, state) {
      final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
      final language = state.uri.queryParameters['language'] ?? 'en';

      debugPrint('🔗 Deep link received: id=$id, language=$language');
      final router = GoRouter.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (id == null) {
          context.pushReplacement('/error?message=Invalid+material+id');
          return;
        }

        // Step 1: Go to dashboard first (ensures proper back button behavior)
        final role = getIt<CacheManager>().getUserRole();
        String dashboardRoute = AppRoutes.studentDashboard;

        if (role == UserRole.admin) {
          dashboardRoute = AppRoutes.adminDashboard;
        } else if (role == UserRole.mentor) {
          dashboardRoute = AppRoutes.mentorDashboard;
        }

        router.go(dashboardRoute);

        // Step 2: Wait 300ms so dashboard builds (important!)
        await Future.delayed(const Duration(milliseconds: 300));

        // Step 3: Push studyMaterial on top of dashboard
        debugPrint(
          '🚀 Navigating to studyMaterial with id=$id, language=$language',
        );
        router.push(
          AppRoutes.studyMaterial,
          extra: {'code': language, 'highlightedMaterialId': id.toString()},
        );
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  ),

  // Handle /openTest?type=mcq&id=123 or /openTest?type=desc&id=123 links
  GoRoute(
    path: '/openTest',
    builder: (context, state) {
      final type = state.uri.queryParameters['type'];
      final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
      debugPrint('🔗 Deep link received: type=$type, id=$id');
      final router = GoRouter.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (type == null || id == null) {
          context.pushReplacement('/error?message=Invalid+test+link');
          return;
        }
        final role = getIt<CacheManager>().getUserRole();
        String dashboardRoute = AppRoutes.studentDashboard;

        if (role == UserRole.admin) {
          router.go(AppRoutes.adminDashboard);
          await Future.delayed(const Duration(milliseconds: 100));
          router.push(AppRoutes.allTests);
        } else if (role == UserRole.mentor) {
          dashboardRoute = AppRoutes.mentorDashboard;
          router.go(dashboardRoute);
        } else {
          router.go(dashboardRoute);
        }

        await Future.delayed(const Duration(milliseconds: 300));
        debugPrint(
          '🚀 [DEBUG] Navigating via AppRoutes names: type=$type, id=$id',
        );
        if (type == 'mcq') {
          router.pushNamed(
            AppRoutes.mcqTestInstructionScreen,
            extra: TestInstructionScreenArgs(testId: id),
          );
        } else if (type == 'desc') {
          router.pushNamed(
            AppRoutes.descriptiveTestInstructionScreen,
            extra: DescTestInstructionScreenArgs(testId: id),
          );
        } else {
          router.pushReplacement('/error?message=Unknown+test+type');
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  ),

  // Handle /openCourse?id=123 link
  GoRoute(
    path: '/openCourse',
    builder: (context, state) {
      final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
      debugPrint('🔗 Deep link received: openCourse id=$id');
      final router = GoRouter.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (id == null) {
          context.pushReplacement('/error?message=Invalid+course+link');
          return;
        }
        final role = getIt<CacheManager>().getUserRole();
        String dashboardRoute = AppRoutes.studentDashboard;

        if (role == UserRole.admin) {
          router.go(AppRoutes.adminDashboard);
          await Future.delayed(const Duration(milliseconds: 100));
          router.push(AppRoutes.allTests);
        } else if (role == UserRole.mentor) {
          dashboardRoute = AppRoutes.mentorDashboard;
          router.go(dashboardRoute);
        } else {
          router.go(dashboardRoute);
        }

        await Future.delayed(const Duration(milliseconds: 300));

        // Push the course list screen first if not admin
        if (role != UserRole.admin) {
          router.push(AppRoutes.courseList);
        }

        final courseRepo = getIt<CourseRepository>();
        final result = await courseRepo.fetchCourses();
        result.fold(
          (failure) => getIt<SnackBarHelper>().showError(
            "Failed to load course details",
          ),
          (courses) {
            try {
              final course = courses.firstWhere((c) => c.id == id);
              router.push(
                AppRoutes.courseDetails,
                extra: CourseDetailsScreenArgs(courseModel: course),
              );
            } catch (e) {
              getIt<SnackBarHelper>().showError("Course not found");
            }
          },
        );
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  ),
  GoRoute(
    path: AppRoutes.splashScreen,
    pageBuilder: (context, state) => _slideTransition(SplashScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.registrationScreen,
    pageBuilder:
        (context, state) => _slideTransition(RegistrationScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.mentorRegistration,
    pageBuilder:
        (context, state) => _slideTransition(MentorRegistrationScreen(), state),
  ),
  GoRoute(
    // AppRoutes.studentDashboard is '/studentDashboard'
    path: AppRoutes.studentDashboard,
    pageBuilder:
        (context, state) => _slideTransition(StudentDashboardScreen(), state),
    routes: [
      // DESC Test Instruction Route
      GoRoute(
        path: 'descriptiveTestScreen',
        pageBuilder: (context, state) => _slideTransition(Container(), state),
        // Placeholder if needed
        routes: [
          GoRoute(
            path: 'descriptiveTestInstructionScreen/:testId',
            pageBuilder: (context, state) {
              final testIdParam = state.pathParameters['testId'];
              final testId = int.tryParse(testIdParam ?? '');
              // If you pass extra args, handle them here
              if (testId == null) {
                return _slideTransition(
                  const ErrorScreen(message: 'Invalid Test ID'),
                  state,
                );
              }
              final args = state.extra as DescTestInstructionScreenArgs?;
              return _slideTransition(
                DescriptiveTestInstructionScreen(
                  testId: args?.testId ?? testId,
                  descTestModel: args?.dailyTestModel,
                  courseId: args?.courseId,
                  isFromCourse: args?.isFromCourse ?? false,
                ),
                state,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: 'mcqTestScreen',
        pageBuilder:
            (context, state) => _slideTransition(MCQTestScreen(), state),
        routes: [
          GoRoute(
            path: 'testInstructionScreen/:testId',
            pageBuilder: (context, state) {
              // Improve parameter handling for both deep links and normal navigation
              final testIdParam = state.pathParameters['testId'];
              final testId = int.tryParse(testIdParam ?? '');

              // Handle both deep link and normal navigation cases
              final args = state.extra as TestInstructionScreenArgs?;
              final finalTestId = args?.testId ?? testId;

              // Add null check and fallback
              if (finalTestId == null) {
                return _slideTransition(
                  const ErrorScreen(message: 'Invalid Test ID'),
                  state,
                );
              }

              return _slideTransition(
                MCQTestInstructionScreen(testId: finalTestId),
                state,
              );
            },
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.mentorDashboard,
    pageBuilder:
        (context, state) => _slideTransition(MentorDashboardScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.mentorEvaluation,
    pageBuilder: (context, state) {
      final args = state.extra as MentorEvaluationScreenArgs;
      return _slideTransition(MentorEvaluationScreen(args: args), state);
    },
  ),
  GoRoute(
    path: AppRoutes.allAssignedTests,
    pageBuilder:
        (context, state) => _slideTransition(AllAssignedTestsScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.freeTestReview,
    pageBuilder:
        (context, state) => _slideTransition(FreeTestReviewScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.testStudentsList,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final testId = extra?['testId'] as int? ?? 0;
      final testName = extra?['testName'] as String? ?? "";
      return _slideTransition(
        TestStudentsListScreen(testId: testId, testName: testName),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.login,
    pageBuilder: (context, state) => _slideTransition(LoginScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.answerWriting,
    pageBuilder:
        (context, state) => _slideTransition(AnswerWritingScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.profile,
    pageBuilder: (context, state) => _slideTransition(ProfileScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.mcqTestScreen,
    pageBuilder: (context, state) => _slideTransition(MCQTestScreen(), state),
  ),
  GoRoute(
    path: '/mcqTestScreen',
    pageBuilder: (context, state) => _slideTransition(MCQTestScreen(), state),
  ),
  GoRoute(
    path: '/testInstructionScreen',
    name: AppRoutes.mcqTestInstructionScreen,
    builder: (context, state) {
      final args = state.extra as TestInstructionScreenArgs?;
      return MCQTestInstructionScreen(
        dailyTestModel: args?.testModal,
        testId: args?.testId,
      );
    },
  ),

  GoRoute(
    path: AppRoutes.testScreen,
    pageBuilder: (context, state) {
      final args = state.extra as TestScreenArgs;

      return _slideTransition(
        TestScreen(
          isFromResult: args.isFromResult,
          dailyTestModel: args.testModal,
          language: args.language,
          hasPrelimsProgress: args.hasPrelimsProgress, // Pass the flag
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.resultScreen,
    pageBuilder: (context, state) {
      final args = state.extra as ResultScreenArgs;
      return _slideTransition(
        ResultScreen(
          isFromTestScreen: args.isFromTest,
          testModel: args.testModal,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.addQuestionScreen,
    pageBuilder: (context, state) => _slideTransition(UploadQuestions(), state),
  ),

  GoRoute(
    path: AppRoutes.reviewQuestion,
    pageBuilder: (context, state) {
      final args = state.extra as ReviewQuestionScreenArgs;
      return _slideTransition(
        ReviewQuestionUploadScreen(
          payload: args.payload,
          isTestUpload: args.isTestUpload,
          isFromStudyMaterial: args.isFromStudyMaterial,
          title: args.title,
          url: args.url,
          language: args.language,
          courseId: args.courseId,
          priceSingle: args.priceSingle,
          priceDual: args.priceDual,
          testType: args.testType,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.descReviewQuestion,
    pageBuilder: (context, state) {
      final args = state.extra as DescReviewQuestionScreenArgs;
      return _slideTransition(
        DescReviewQuestionUploadScreen(
          payload: args.payload,
          courseId: args.courseId,
          priceSingle: args.priceSingle,
          priceDual: args.priceDual,
          testType: args.testType,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.questionPreviewScreen,
    pageBuilder: (context, state) {
      final extra = state.extra as QuestionPreviewScreenArgs;
      return _slideTransition(
        QuestionPreviewScreen(
          questions: extra.questions,
          testName: extra.testName,
          performanceSummary: extra.performanceSummary,
          testModel: extra.testModel,
          detailedResults: extra.detailedResults,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.descriptiveTestScreen,
    pageBuilder: (context, state) {
      final args = state.extra as DescTestScreenArgs;
      return _slideTransition(
        DescriptiveTestScreen(
          descTestModel: args.dailyTestModel,
          initialIndex: args.initialIndex,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.descriptiveTestResultScreen,
    pageBuilder: (context, state) {
      final testName = state.extra as String;
      return _slideTransition(
        DescriptiveTestResultScreen(testName: testName),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.descAnswerScreen,
    pageBuilder: (context, state) {
      final args = state.extra as DescriptiveAnswersScreenArgs;
      return _slideTransition(DescriptiveAnswersScreen(args: args), state);
    },
  ),
  GoRoute(
    path: AppRoutes.descAnswerDetail,
    pageBuilder: (context, state) {
      final args = state.extra as DescriptiveAnswerDetailScreenArgs;
      return _slideTransition(DescriptiveAnswerDetailScreen(args: args), state);
    },
  ),
  GoRoute(
    path: AppRoutes.peerReviewAnswer,
    pageBuilder: (context, state) {
      final args = state.extra as PeerReviewAnswerScreenArgs;
      return _slideTransition(PeerReviewAnswerScreen(args: args), state);
    },
  ),

  GoRoute(
    path: AppRoutes.descriptiveTestInstructionScreen,
    name: AppRoutes.descriptiveTestInstructionScreen,
    pageBuilder: (context, state) {
      final args = state.extra as DescTestInstructionScreenArgs;

      return _slideTransition(
        DescriptiveTestInstructionScreen(
          descTestModel: args.dailyTestModel,
          testId: args.testId,
          courseId: args.courseId,
          isFromCourse: args.isFromCourse,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.descFullQuestions,
    pageBuilder: (context, state) {
      final args = state.extra as DescFullQuestionsScreenArgs;
      return _slideTransition(
        DescFullQuestionsScreen(
          testId: args.testId,
          testName: args.testName,
          courseId: args.courseId,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.uploadStudyMaterial,
    pageBuilder: (context, state) {
      return _slideTransition(UploadStudyMaterialScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.languageSelection,
    pageBuilder: (context, state) {
      return _slideTransition(LanguageSelectionScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.studyMaterial,
    builder: (context, state) {
      final params = state.extra as Map<String, String>?;
      final language = params?['code'] ?? 'en';
      final highlightedId = params?['highlightedMaterialId'];
      return StudyMaterialListScreen(
        selectedLanguage: language,
        highlightedMaterialId: highlightedId, // ✅ Now passing the ID!
      );
    },
  ),
  GoRoute(
    path: AppRoutes.requestResetPassword,
    pageBuilder: (context, state) {
      return _slideTransition(RequestResetPasswordScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.resetPassword,
    pageBuilder: (context, state) {
      return _slideTransition(ResetPasswordScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.analyticsScreen,
    pageBuilder: (context, state) {
      return _slideTransition(AnalyticsScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.allSubjectsAnalyticsScreen,
    pageBuilder: (context, state) {
      final params = state.extra as List<SubjectScore>;
      return _slideTransition(
        BlocProvider(
          create:
              (context) => DetailedAnalyticsBloc(
                repository: getIt<AnalyticsRepository>(),
                initialSubjects: params,
              ),
          child: AllSubjectsAnalyticsScreen(subjectsData: params),
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.allDifficultyAnalyticsScreen,
    pageBuilder: (context, state) {
      final params = state.extra as List<Difficulty>;
      return _slideTransition(
        BlocProvider(
          create:
              (context) => DetailedAnalyticsBloc(
                repository: getIt<AnalyticsRepository>(),
                initialDifficulty: params,
              ),
          child: AllDifficultyAnalyticsScreen(difficultyData: params),
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.allQuestionTypesAnalyticsScreen,
    pageBuilder: (context, state) {
      final params = state.extra as List<Difficulty>;
      return _slideTransition(
        BlocProvider(
          create:
              (context) => DetailedAnalyticsBloc(
                repository: getIt<AnalyticsRepository>(),
                initialQuestionTypes: params,
              ),
          child: AllQuestionTypesAnalyticsScreen(questionTypesData: params),
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.omrScreen,
    pageBuilder: (context, state) {
      final args = state.extra as OMRScreenArgs;
      return _slideTransition(
        OMRScreen(testModel: args.testModal, language: args.language),
        state,
      );
    },
  ),

  // RESTORED ROOT LEVEL ROUTES FOR COMPATIBILITY
  GoRoute(
    path: AppRoutes.prelimsInstructionsScreen,
    name: AppRoutes.prelimsInstructionsScreen,
    pageBuilder: (context, state) {
      final args = state.extra as PrelimsInstructionScreenArgs?;
      return _slideTransition(
        PrelimsMcqInstructionScreen(
          testId: args?.testId,
          testModel: args?.testModal,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.addCourse,
    pageBuilder: (context, state) => _slideTransition(AddCourseScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.courseList,
    pageBuilder:
        (context, state) => _slideTransition(PaidCourseListScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.courseDetails,
    pageBuilder: (context, state) {
      final args = state.extra as CourseDetailsScreenArgs;
      return _slideTransition(
        CourseDetailsScreen(courseModel: args.courseModel),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.mentorAssign,
    pageBuilder:
        (context, state) => _slideTransition(const MentorAssignScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.mentorList,
    pageBuilder:
        (context, state) => _slideTransition(const MentorListScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.editMentor,
    pageBuilder: (context, state) {
      final args = state.extra as EditMentorScreenArgs;
      return _slideTransition(EditMentorScreen(mentor: args.mentor), state);
    },
  ),
  GoRoute(
    path: AppRoutes.adminDashboard,
    pageBuilder:
        (context, state) =>
            _slideTransition(const AdminDashboardScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.assignMentorDetail,
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final testName = extra?['testName'] as String? ?? "";
      final testId = extra?['testId'] as int? ?? 0;
      return _slideTransition(
        AssignMentorDetailScreen(testName: testName, testId: testId),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.assessmentTypeSelection,
    pageBuilder: (context, state) {
      final args = state.extra as AssessmentTypeSelectionScreenArgs;
      return _slideTransition(AssessmentTypeSelectionScreen(args: args), state);
    },
  ),
  GoRoute(
    path: AppRoutes.allTests,
    pageBuilder: (context, state) {
      return _slideTransition(
        BlocProvider(
          create:
              (context) =>
                  AllTestBloc(getIt<TestRepository>())..add(FetchAllTests()),
          child: const AllTestScreen(),
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.studentEvaluationResult,
    pageBuilder: (context, state) {
      final args = state.extra as StudentEvaluationResultScreenArgs;
      return _slideTransition(StudentEvaluationResultScreen(args: args), state);
    },
  ),
  GoRoute(
    path: AppRoutes.addProduct,
    pageBuilder:
        (context, state) => _slideTransition(const AddProductScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.createNotification,
    pageBuilder: (context, state) {
      final prefill = state.extra as NotificationModel?;
      return _slideTransition(
        CreateNotificationScreen(prefill: prefill),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.notificationHistory,
    pageBuilder:
        (context, state) =>
            _slideTransition(const NotificationHistoryScreen(), state),
  ),
];

Page<dynamic> _slideTransition(Widget screen, GoRouterState state) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
