import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import 'routes.dart';

class AppRouter {
  static late final GoRouter _router;

  static void init(bool isLoggedIn) {
    _router = GoRouter(
      debugLogDiagnostics: true,
      requestFocus: true,
      initialLocation:
          isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
      routes: appRoutes,
    );
  }

  static GoRouter get router => _router;
}
