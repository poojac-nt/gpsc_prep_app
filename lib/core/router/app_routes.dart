import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../domain/entities/user_model.dart';
import 'routes.dart';

class AppRouter {
  static late final GoRouter _router;
  static void init(bool isLoggedIn) {
    _router = GoRouter(
      debugLogDiagnostics: true,
      requestFocus: true,
      initialLocation: isLoggedIn ? AppRoutes.splashScreen : AppRoutes.login,
      redirect: (context, state) async {
        final cache = getIt<CacheManager>();
        final UserModel? user = await cache.getInitUser();
        if (user == null) {
          return AppRoutes.login;
        }
      },
      routes: appRoutes,
    );
  }

  static GoRouter get router => _router;
}
