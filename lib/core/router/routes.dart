import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/home/home_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/regitration_screen/registration_screen.dart';
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
    path: AppRoutes.home,
    pageBuilder: (context, state) => _slideTransition(HomeScreen(), state),
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
    path: AppRoutes.testScreen,
    pageBuilder: (context, state) => _slideTransition(MCQTestScreen(), state),
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
