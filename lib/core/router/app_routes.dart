import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/refresh_stream.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../domain/entities/user_model.dart';
import 'routes.dart';

class AppRouter {
  static late final GoRouter _router;

  static void init(bool isLoggedIn, AuthBloc authBloc) {
    _router = GoRouter(
      debugLogDiagnostics: true,
      requestFocus: true,
      initialLocation: isLoggedIn ? AppRoutes.splashScreen : AppRoutes.login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) async {
        final cache = getIt<CacheManager>();
        final UserModel? user = await cache.getInitUser();
        final authState = authBloc.state;

        final loggingIn = state.matchedLocation == AppRoutes.login;
        final registering =
            state.matchedLocation == AppRoutes.registrationScreen;
        final requestResetPassword =
            state.matchedLocation == AppRoutes.requestResetPassword;
        final resetPassword = state.matchedLocation == AppRoutes.resetPassword;

        // Redirect to Login if user is null OR if AuthState is Unauthenticated
        if (user == null || authState is Unauthenticated) {
          if (!loggingIn &&
              !registering &&
              !requestResetPassword &&
              !resetPassword) {
            return AppRoutes.login;
          }
        }

        // Redirect to Splash if user exists and trying to access login/register
        if (user != null &&
            authState is! Unauthenticated &&
            (loggingIn || registering)) {
          return AppRoutes.splashScreen;
        }

        return null;
      },
      routes: appRoutes,
    );
  }

  static GoRouter get router => _router;
}
