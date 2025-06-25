import 'package:flutter/material.dart';

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
