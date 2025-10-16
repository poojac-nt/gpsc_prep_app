import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor_dashborad_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/student_dashboard_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_answers_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_test_result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/error_screen/error_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/preview_screen/questions_preview_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/registration_screen/registration_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/splash_screen/splash_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/admin/upload_study_maerial_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/student/language_selection_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/study_material/student/student_study_material_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_instruction_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/desc_review_questions_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/mcq_review_question_upload_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../presentation/screens/descriptive_test_module/answer_writing_screen.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test_instruction_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/test/mcq_test_screen.dart';

final List<GoRoute> appRoutes = [
  // Handle /openTest?type=mcq&id=123 or /openTest?type=desc&id=123 links
  GoRoute(
    path: '/openTest',
    builder: (context, state) {
      final type = state.uri.queryParameters['type'];
      final id = int.tryParse(state.uri.queryParameters['id'] ?? '');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (type == null || id == null) {
          context.pushReplacement('/error?message=Invalid+test+link');
        } else if (type == 'mcq') {
          context.pushReplacement(
            '/studentDashboard/mcqTestScreen/testInstructionScreen/$id',
          );
        } else if (type == 'desc') {
          context.pushReplacement(
            '/studentDashboard/descriptiveTestScreen/descriptiveTestInstructionScreen/$id',
          );
        } else {
          context.pushReplacement('/error?message=Unknown+test+type');
        }
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
    // AppRoutes.studentDashboard is '/studentDashboard'
    path: AppRoutes.studentDashboard,
    pageBuilder:
        (context, state) => _slideTransition(StudentDashboardScreen(), state),
    routes: [
      // MCQ Test Instruction Route
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
              return _slideTransition(
                DescriptiveTestInstructionScreen(testId: testId),
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
        dailyTestModel: args?.dailyTestModel,
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
          dailyTestModel: args.dailyTestModel,
          language: args.language,
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
          dailyTestModel: args.dailyTestModel,
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
        DescReviewQuestionUploadScreen(payload: args.payload),
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
      final descTestModel = state.extra as DescTestModel;
      return _slideTransition(
        DescriptiveAnswersScreen(descTestModel: descTestModel),
        state,
      );
    },
  ),

  GoRoute(
    path: AppRoutes.descriptiveTestInstructionScreen,
    pageBuilder: (context, state) {
      final args = state.extra as DescTestInstructionScreenArgs;

      return _slideTransition(
        DescriptiveTestInstructionScreen(descTestModel: args.dailyTestModel),
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
      final lang = state.extra as Map<String, String>?;
      return StudyMaterialListScreen(
        selectedLanguage: lang?['name'] ?? 'English',
      );
    },
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
