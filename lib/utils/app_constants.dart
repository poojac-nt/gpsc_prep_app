import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppColors {
  static Color primary = Color(0xff3b82f6);
  static Color scaffoldColor = Color(0xfff7f8f9);
  static Color accentColor = Colors.grey.shade300;
}

abstract class AppThemeData {
  static ThemeData themData = ThemeData(
    primaryColor: AppColors.primary,
    fontFamily: 'Inter',
    splashColor: AppColors.primary.withAlpha(2),
    inputDecorationTheme: InputDecorationTheme(focusColor: AppColors.primary),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withAlpha(50),
      selectionHandleColor: AppColors.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.scaffoldColor,
      surfaceTintColor: Colors.white,
      titleSpacing: 0,
    ),
    scaffoldBackgroundColor: Color(0xfff7f8f9),
    dividerTheme: DividerThemeData(color: Colors.transparent),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      refreshBackgroundColor: AppColors.scaffoldColor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
  );
}

abstract class AppPaddings {
  static double defaultPadding = 12;
  static double appPaddingInt = 10;
}

abstract class AppBorders {
  static BorderRadius borderRadius = BorderRadius.circular(8.r);
}

abstract class AppTexts {
  static TextStyle labelTextStyle = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle title = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  static TextStyle subTitle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: Colors.grey[700],
  );
  static TextStyle heading = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle titleTextStyle = TextStyle(
    fontSize: 20.sp,
    fontVariations: [FontVariation.weight(800)],
  );
}

abstract class AppRoutes {
  static const String splashScreen = '/splashScreen';
  static const String registrationScreen = '/registrationScreen';
  static const String studentDashboard = '/studentDashboard';
  static const String mentorDashboard = '/mentorDashboard';
  static const String login = '/login';
  static const String answerWriting = '/answerWriting';
  static const String profile = '/profile';
  static const String mcqTestScreen = '/mcqTestScreen';
  // static const String testInstructionScreen = '/testInstructionScreen';
  static const String testInstructionScreen =
      '/studentDashboard/mcqTestScreen/testInstructionScreen';
  static const String testScreen = '/testScreen';
  static const String resultScreen = '/resultScreen';
  static const String addQuestionScreen = '/addQuestionScreen';
  static const String reviewQuestion = '/reviewQuestionScreen';
  static const String questionPreviewScreen = '/questionPreviewScreen';
  static const String descriptiveTestScreen = '/descriptiveTestScreen';
  static const String descriptiveTestResultScreen =
      '/descriptiveTestResultScreen';
  static const String descriptiveTestInstructionScreen =
      '/descriptiveTestInstructionScreen';
}
