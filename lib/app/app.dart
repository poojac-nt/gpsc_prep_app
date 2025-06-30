import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
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
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        theme: AppThemeData.themData,
      ),
    );
  }
}
