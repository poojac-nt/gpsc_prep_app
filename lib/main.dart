import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_screen.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        title: 'GPSC Prep',
        debugShowCheckedModeBanner: false,
        theme: AppThemeData.themData,
        home: const AuthScreen(),
      ),
    );
  }
}
