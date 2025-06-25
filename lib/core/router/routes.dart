import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/login_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/home/home_screen.dart';
import 'package:gpsc_prep_app/presentation/screens/test/mcq_test_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

final List<GoRoute> appRoutes = [
  GoRoute(
    path: AppRoutes.auth,
    pageBuilder: (context, state) => _slideTransition(AuthScreen(), state),
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
