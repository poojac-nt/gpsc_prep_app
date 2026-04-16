import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/firebase_options.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_course/course_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/admin_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/bar_chart/bar_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/all_assigned_tests_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/test_students_list/test_students_list_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test_result/mains_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit%20profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit_mentor/edit_mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_course_details/fetch_course_details_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor/mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_assignment/mentor_assignment_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_dashboard/mentor_dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_evaluation/mentor_evaluation_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/detailed_peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/submit_peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pending_submissions/pending_submissions_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/purchase/purchase_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/result/result_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/subject/subject_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test_wise_submissions/test_wise_submissions_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppServices {
  Future<void> appInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // For Android
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    await MobileAds.instance.initialize();

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await FlutterLocalNotificationsPlugin().initialize(
      settings: initializationSettings,
    );

    await ScreenUtil.ensureScreenSize();

    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
    await MediaStore.ensureInitialized();
    await setupInitializer();

    await getIt<SharedPrefHelper>().init();

    final cacheManager = getIt<CacheManager>();
    final UserModel? user = await cacheManager.getInitUser();
    final authBloc = getIt<AuthBloc>();
    AppRouter.init(user != null, authBloc);

    final supabase = getIt<SupabaseHelper>().supabase;
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final currentLocation =
          AppRouter.router.routerDelegate.currentConfiguration.uri.toString();

      if (event == AuthChangeEvent.signedOut) {
        AppRouter.router.go(AppRoutes.login);
      } else if (event == AuthChangeEvent.passwordRecovery &&
          currentLocation != AppRoutes.resetPassword) {
        AppRouter.router.go(AppRoutes.resetPassword);
      }
    });
  }

  static final List<BlocProvider> _blocProviders = [
    BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
    BlocProvider<QuestionBloc>(create: (_) => getIt<QuestionBloc>()),
    BlocProvider<TestBloc>(create: (_) => getIt<TestBloc>()),
    BlocProvider<EditProfileBloc>(create: (_) => getIt<EditProfileBloc>()),
    BlocProvider<UploadQuestionsBloc>(
      create: (_) => getIt<UploadQuestionsBloc>(),
    ),
    BlocProvider<TimerBloc>(create: (_) => getIt<TimerBloc>()),
    BlocProvider<DailyTestBloc>(create: (_) => getIt<DailyTestBloc>()),
    BlocProvider<QuestionCubit>(create: (_) => getIt<QuestionCubit>()),
    BlocProvider<TestCubit>(create: (_) => getIt<TestCubit>()),
    BlocProvider<ConnectivityBloc>(create: (_) => getIt<ConnectivityBloc>()),
    BlocProvider<DownLoadPdfBloc>(create: (_) => getIt<DownLoadPdfBloc>()),
    BlocProvider<DailyDescTestBloc>(create: (_) => getIt<DailyDescTestBloc>()),
    BlocProvider<DashboardBloc>(create: (_) => getIt<DashboardBloc>()),
    BlocProvider<PieChartBloc>(create: (_) => getIt<PieChartBloc>()),
    BlocProvider<StudyMaterialBloc>(create: (_) => getIt<StudyMaterialBloc>()),
    BlocProvider<FetchSingleTestBloc>(
      create: (_) => getIt<FetchSingleTestBloc>(),
    ),
    BlocProvider<BarChartBloc>(create: (_) => getIt<BarChartBloc>()),
    BlocProvider<ResultBloc>(create: (_) => getIt<ResultBloc>()),
    BlocProvider<AnalyticsBloc>(create: (_) => getIt<AnalyticsBloc>()),
    BlocProvider<DetailedAnalyticsBloc>(
      create: (_) => getIt<DetailedAnalyticsBloc>(),
    ),
    BlocProvider<PrelimsTestBloc>(create: (_) => getIt<PrelimsTestBloc>()),
    BlocProvider<CourseBloc>(create: (_) => getIt<CourseBloc>()),
    BlocProvider<SubjectBloc>(create: (_) => getIt<SubjectBloc>()),
    BlocProvider<PeerReviewBloc>(create: (_) => getIt<PeerReviewBloc>()),
    BlocProvider<DetailedPeerReviewBloc>(
      create: (_) => getIt<DetailedPeerReviewBloc>(),
    ),
    BlocProvider<SubmitPeerReviewBloc>(
      create: (_) => getIt<SubmitPeerReviewBloc>(),
    ),
    BlocProvider<PurchaseBloc>(create: (_) => getIt<PurchaseBloc>()),
    BlocProvider<PendingSubmissionsBloc>(
      create: (_) => getIt<PendingSubmissionsBloc>(),
    ),
    BlocProvider<TestWiseSubmissionsBloc>(
      create: (_) => getIt<TestWiseSubmissionsBloc>(),
    ),
    BlocProvider<MentorAssignmentBloc>(
      create: (_) => getIt<MentorAssignmentBloc>(),
    ),
    BlocProvider<AdminBloc>(create: (_) => getIt<AdminBloc>()),
    BlocProvider<MentorBloc>(create: (_) => getIt<MentorBloc>()),
    BlocProvider<EditMentorBloc>(create: (_) => getIt<EditMentorBloc>()),
    BlocProvider<MentorDashboardBloc>(
      create: (_) => getIt<MentorDashboardBloc>(),
    ),
    BlocProvider<AllAssignedTestsBloc>(
      create: (_) => getIt<AllAssignedTestsBloc>(),
    ),
    BlocProvider<TestStudentsListBloc>(
      create: (_) => getIt<TestStudentsListBloc>(),
    ),
    BlocProvider<MentorEvaluationBloc>(
      create: (_) => getIt<MentorEvaluationBloc>(),
    ),
    BlocProvider<MainsTestReviewBloc>(
      create: (_) => getIt<MainsTestReviewBloc>(),
    ),
    BlocProvider<FreeTestReviewBloc>(
      create: (_) => getIt<FreeTestReviewBloc>(),
    ),
    BlocProvider<FetchCourseDetailsBloc>(
      create: (_) => getIt<FetchCourseDetailsBloc>(),
    ),
    BlocProvider<AddProductBloc>(create: (_) => getIt<AddProductBloc>()),
  ];

  List<BlocProvider> get blocProviders => _blocProviders;
}
