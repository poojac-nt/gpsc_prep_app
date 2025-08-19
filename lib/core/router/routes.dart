import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/mentor_dashborad_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/student_dashboard_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/descriptive_test_result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/error_screen/error_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/preview_screen/questions_preview_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/registration_screen/registration_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/splash_screen/splash_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_instruction_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/desc_review_questions_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/mcq_review_question_upload_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../presentation/screens/answer_writing/answer_writing_screen.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test.dart';
import '../../presentation/screens/descriptive_test_module/descriptive_test_instruction_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/test/mcq_test_screen.dart';

final List<GoRoute> appRoutes = [
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
    // Assuming AppRoutes.studentDashboard is '/studentDashboard'
    path: AppRoutes.studentDashboard,
    pageBuilder:
        (context, state) => _slideTransition(StudentDashboardScreen(), state),
    routes: [
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
                // Handle invalid testId case
                return _slideTransition(
                  const ErrorScreen(message: 'Invalid Test ID'),
                  state,
                );
              }

              return _slideTransition(
                TestInstructionScreen(testId: finalTestId),
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
    name: AppRoutes.testInstructionScreen,
    builder: (context, state) {
      final args = state.extra as TestInstructionScreenArgs?;
      return TestInstructionScreen(
        // testId: args?.testId,
        dailyTestModel: args?.dailyTestModel,
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
      final extra = state.extra as String;
      return _slideTransition(QuestionPreviewScreen(testName: extra), state);
    },
  ),
  GoRoute(
    path: AppRoutes.descriptiveTestScreen,
    pageBuilder: (context, state) {
      return _slideTransition(DescriptiveTestScreen(), state);
    },
  ),
  GoRoute(
    path: AppRoutes.descriptiveTestResultScreen,
    pageBuilder:
        (context, state) =>
            _slideTransition(DescriptiveTestResultScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.descriptiveTestInstructionScreen,
    pageBuilder: (context, state) {
      return _slideTransition(DescriptiveTestInstructionScreen(), state);
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
