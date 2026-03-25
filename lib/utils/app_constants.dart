import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppColors {
  static Color primary = Color(0xff3b82f6);
  static Color scaffoldColor = Color(0xfff7f8f9);
  static Color accentColor = Colors.grey.shade300;

  // Analytics Colors
  static const Color analyticsBg = Color(0xFFF8F9FB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray700 = Color(0xFF4B5563);
  static const Color gray900 = Color(0xFF111827);

  // Difficulty Level Colors
  static const Color green500 = Color(0xFF10B981);
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green800 = Color(0xFF065F46);

  static const Color orange500 = Color(0xFFF59E0B);
  static const Color orange100 = Color(0xFFFEF3C7);
  static const Color orange800 = Color(0xFF92400E);

  static const Color red500 = Color(0xFFEF4444);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red800 = Color(0xFF991B1B);
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
  static double dashboardContainerPadding = 25;
}

abstract class AppBorders {
  static BorderRadius borderRadius = BorderRadius.circular(8.r);
  static BorderRadius dashboardBorderRadius = BorderRadius.circular(25.r);
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
  static TextStyle dashboardContainerTitle = TextStyle(
    color: Colors.black,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle dashboardSmallTexts = TextStyle(
    color: Colors.black54,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );
  static TextStyle dashboardMediumTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16.sp,
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
  static const String mcqTestInstructionScreen = '/testInstructionScreen';
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
  static const String descReviewQuestion = '/descReviewQuestion';
  static const String descAnswerScreen = '/descAnswerScreen';
  static const String descAnswerDetail = '/descAnswerDetail';
  static const String peerReviewAnswer = '/peerReviewAnswer';
  static const String descFullQuestions = '/descFullQuestions';
  static const String uploadStudyMaterial = '/uploadStudyMaterial';
  static const String languageSelection = '/languageSelection';
  static const String studyMaterial = '/studyMaterial';
  static const String requestResetPassword = '/requestResetPassword';
  static const String resetPassword = '/resetPassword';
  static const String analyticsScreen = '/analyticsScreen';
  static const String allSubjectsAnalyticsScreen =
      '/allSubjectsAnalyticsScreen';
  static const String allDifficultyAnalyticsScreen =
      '/allDifficultyAnalyticsScreen';
  static const String allQuestionTypesAnalyticsScreen =
      '/allQuestionTypesAnalyticsScreen';
  static const String omrScreen = '/omrScreen';
  static const String prelimsMcqTestScreen = '/fullLengthMcqTestScreen';
  static const String prelimsInstructionsScreen = '/prelimsInstructionsScreen';
  static const String addCourse = '/addCourse';
  static const String courseList = '/courseList';
  static const String courseDetails = '/courseDetails';
  static const String mentorRegistration = '/mentorRegistration';
  static const String mentorList = '/mentorList';
  static const String editMentor = '/editMentor';
  static const String mentorEvaluation = '/mentorEvaluation';
  static const String mentorAssign = '/mentorAssign';
  static const String adminDashboard = '/adminDashboard';
  static const String assignMentorDetail = '/assignMentorDetail';
  static const String assessmentTypeSelection = '/assessmentTypeSelection';
  static const String allAssignedTests = '/allAssignedTests';
  static const String testStudentsList = '/testStudentsList';
  static const String allTests = '/allTests';
  static const String studentEvaluationResult = '/studentEvaluationResult';
  static const String freeTestReview = '/freeTestReview';
}

class AdUnitIds {
  static const String interstitialUnitId =
      'ca-app-pub-4018950905393948/9479145944';
  static const String bannerUnitId = 'ca-app-pub-4018950905393948/8301827460';
}
