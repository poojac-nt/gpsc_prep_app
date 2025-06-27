import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routes.dart';

class AppRouter {
  static late final GoRouter _router;

  static void init() {
    _router = GoRouter(
      debugLogDiagnostics: true,
      requestFocus: true,
      initialLocation: AppRoutes.login,
      routes: appRoutes,
      redirect: (context, state) {
        final supabase = Supabase.instance.client;
        final session = supabase.auth.currentSession;

        if (session != null) {
          return AppRoutes.home;
        } else {
          return AppRoutes.login;
        }
      },
    );
  }

  static GoRouter get router => _router;
}
