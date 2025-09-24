import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../core/di/di.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        listenWhen: (previous, current) => current is Unauthenticated,
        child: MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: AppThemeData.themData,
        ),
      ),
    );
  }
}
