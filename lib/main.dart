import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

void main() {
  AppRouter.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp.router(
        title: 'GPSC Prep',
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.themData,
      ),
    );
  }
}
