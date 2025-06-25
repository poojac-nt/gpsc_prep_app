import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppThemeData {
  static ThemeData themData = ThemeData(
    fontFamily: 'Inter',
    splashColor: Colors.black.withAlpha(2),
    inputDecorationTheme: InputDecorationTheme(focusColor: Colors.black),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: Colors.black.withAlpha(2),
      selectionHandleColor: Colors.black,
    ),
    appBarTheme: AppBarTheme(backgroundColor: Colors.white),
    scaffoldBackgroundColor: Colors.white,
    dividerTheme: DividerThemeData(color: Colors.transparent),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.black,
      refreshBackgroundColor: Colors.white,
    ),
  );
}

abstract class AppPaddings {
  static EdgeInsets defaultPadding = const EdgeInsets.all(12);
  static double appPaddingInt = 10;
}

abstract class AppBorders {
  static BorderRadius borderRadius = BorderRadius.circular(8.r);
}

abstract class AppTexts {
  static TextStyle labelTextStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
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
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String login = '/login';
  static const String answerWriting = '/answerWriting';
  static const String profile = '/profile';
  static const String testScreen = '/testScreen';
}
