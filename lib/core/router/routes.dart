import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/registration_screen/registration_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/result_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_instruction_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/test_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../presentation/screens/answer_writing/answer_writing_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/test/mcq_test_screen.dart';

final List<GoRoute> appRoutes = [
  GoRoute(
    path: AppRoutes.registrationScreen,
    pageBuilder:
        (context, state) => _slideTransition(RegistrationScreen(), state),
  ),
  GoRoute(
    path: AppRoutes.dashboard,
    pageBuilder: (context, state) => _slideTransition(DashboardScreen(), state),
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
    path: AppRoutes.testInstructionScreen,
    pageBuilder: (context, state) {
      final args = state.extra as TestInstructionScreenArgs;
      return _slideTransition(
        TestInstructionScreen(
          dailyTestModel: args.dailyTestModel,
          availableLanguages: args.availableLanguages,
        ),
        state,
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
          testId: args.testId,
          testDuration: args.testDuration,
          testName: args.testName,
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
          testName: args.testName,
          testId: args.testId,
        ),
        state,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.addQuestionScreen,
    pageBuilder: (context, state) => _slideTransition(UploadQuestions(), state),
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
