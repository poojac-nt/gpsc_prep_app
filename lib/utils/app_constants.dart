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
}

abstract class AppBorders {
  static BorderRadius borderRadius = BorderRadius.circular(8.r);
}

abstract class AppTexts {
  static TextStyle labelTextStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
}
