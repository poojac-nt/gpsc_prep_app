import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/admin_repository.dart';
import 'package:gpsc_prep_app/data/repositories/analytics_repository.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/data/repositories/mentor_repository.dart';
import 'package:gpsc_prep_app/data/repositories/peer_review_repository.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/data/repositories/purchase_repository.dart';
import 'package:gpsc_prep_app/data/repositories/study_material_repository.dart';
import 'package:gpsc_prep_app/data/repositories/subject_repository.dart';
import 'package:gpsc_prep_app/data/repositories/notification_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/prelims_test_progress.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_course/course_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/admin_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/all_test/all_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/bar_chart/bar_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/all_assigned_tests_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/test_students_list/test_students_list_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit%20profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/edit_mentor/edit_mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_course_details/fetch_course_details_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor/mentor_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_assignment/mentor_assignment_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_dashboard/mentor_dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_evaluation/mentor_evaluation_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/detailed_peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/submit_peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pending_submissions/pending_submissions_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/result/result_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/subject/subject_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test_wise_submissions/test_wise_submissions_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/utils/services/fcm_service.dart';
import 'package:hive_flutter/adapters.dart';

import '../../presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import '../../presentation/blocs/descriptive_test_result/mains_test_review_bloc.dart';
import '../../presentation/blocs/purchase/purchase_bloc.dart';
import '../../presentation/screens/test_module/cubit/question/question_cubit.dart';
import '../../utils/services/iap_service.dart';

final getIt = GetIt.instance;
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> setupInitializer() async {
  setupHelpers();
  setupRepositories();
  setupBlocs();
  await setUpHive();
}

void setupHelpers() {
  getIt.registerLazySingleton<SharedPrefHelper>(SharedPrefHelper.new);
  getIt.registerLazySingleton<LogHelper>(LogHelper.new);

  getIt.registerLazySingleton<CacheManager>(
    () => CacheManager(getIt<SharedPrefHelper>()),
  );

  getIt.registerLazySingleton<SnackBarHelper>(
    () => SnackBarHelper(scaffoldMessengerKey),
  );

  getIt.registerLazySingleton<SupabaseHelper>(
    () => SupabaseHelper(
      getIt<LogHelper>(),
      getIt<SnackBarHelper>(),
      getIt<CacheManager>(),
    ),
  );

  getIt.registerLazySingleton<FCMService>(
    () => FCMService(getIt<SupabaseHelper>()),
  );

  getIt.registerLazySingleton<IapService>(() => IapService(getIt<LogHelper>()));
}

void setupRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<SupabaseHelper>()),
  );

  getIt.registerLazySingleton<TestRepository>(
    () => TestRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<StudyMaterialRepository>(
    () => StudyMaterialRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<PrelimsProgressRepository>(
    () => PrelimsProgressRepository(getIt<Box<PrelimsTestProgress>>()),
  );
  getIt.registerLazySingleton<CourseRepository>(
    () => CourseRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<SubjectRepository>(
    () => SubjectRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<PeerReviewRepository>(
    () => PeerReviewRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<MentorRepository>(
    () => MentorRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepository(getIt<SupabaseHelper>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<SupabaseHelper>()),
  );
}

void setupBlocs() {
  getIt.registerLazySingleton<ConnectivityBloc>(() => ConnectivityBloc());
  getIt.registerLazySingleton<DownLoadPdfBloc>(() => DownLoadPdfBloc());
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>(), getIt<CacheManager>()),
  );
  getIt.registerLazySingleton<EditProfileBloc>(
    () => EditProfileBloc(
      getIt<CacheManager>(),
      getIt<AuthRepository>(),
      getIt<SnackBarHelper>(),
      getIt<LogHelper>(),
    ),
  );
  getIt.registerLazySingleton<QuestionBloc>(
    () => QuestionBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<TestBloc>(
    () => TestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<UploadQuestionsBloc>(
    () => UploadQuestionsBloc(getIt<CourseRepository>()),
  );
  getIt.registerLazySingleton<TimerBloc>(() => TimerBloc());
  getIt.registerLazySingleton<PieChartBloc>(
    () => PieChartBloc(getIt<AnalyticsRepository>()),
  );
  getIt.registerLazySingleton<DailyTestBloc>(
    () => DailyTestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<TestCubit>(() => TestCubit());
  getIt.registerLazySingleton<QuestionCubit>(() => QuestionCubit());
  getIt.registerLazySingleton<DailyDescTestBloc>(
    () => DailyDescTestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<DashboardBloc>(
    () => DashboardBloc(getIt<AnalyticsRepository>()),
  );
  getIt.registerLazySingleton<StudyMaterialBloc>(
    () => StudyMaterialBloc(getIt<StudyMaterialRepository>()),
  );
  getIt.registerLazySingleton<FetchSingleTestBloc>(
    () => FetchSingleTestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<BarChartBloc>(
    () => BarChartBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<ResultBloc>(
    () => ResultBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<AnalyticsBloc>(
    () => AnalyticsBloc(getIt<AnalyticsRepository>()),
  );
  getIt.registerLazySingleton<DetailedAnalyticsBloc>(
    () => DetailedAnalyticsBloc(repository: getIt<AnalyticsRepository>()),
  );
  getIt.registerLazySingleton<CourseBloc>(
    () => CourseBloc(getIt<CourseRepository>()),
  );
  getIt.registerLazySingleton<SubjectBloc>(
    () => SubjectBloc(getIt<SubjectRepository>()),
  );
  getIt.registerLazySingleton<PeerReviewBloc>(
    () => PeerReviewBloc(getIt<PeerReviewRepository>()),
  );
  getIt.registerLazySingleton<DetailedPeerReviewBloc>(
    () => DetailedPeerReviewBloc(getIt<PeerReviewRepository>()),
  );
  getIt.registerLazySingleton<SubmitPeerReviewBloc>(
    () => SubmitPeerReviewBloc(getIt<PeerReviewRepository>()),
  );
  getIt.registerLazySingleton<PurchaseBloc>(
    () => PurchaseBloc(getIt<PurchaseRepository>(), getIt<IapService>()),
  );
  getIt.registerLazySingleton<PendingSubmissionsBloc>(
    () => PendingSubmissionsBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<TestWiseSubmissionsBloc>(
    () => TestWiseSubmissionsBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<MentorAssignmentBloc>(
    () => MentorAssignmentBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<AdminBloc>(
    () => AdminBloc(getIt<AdminRepository>()),
  );
  getIt.registerLazySingleton<AddProductBloc>(
    () => AddProductBloc(getIt<AdminRepository>()),
  );
  getIt.registerLazySingleton<MentorBloc>(
    () => MentorBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<EditMentorBloc>(
    () => EditMentorBloc(getIt<MentorRepository>(), getIt<CacheManager>()),
  );
  getIt.registerLazySingleton<MentorDashboardBloc>(
    () => MentorDashboardBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<AllAssignedTestsBloc>(
    () => AllAssignedTestsBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<TestStudentsListBloc>(
    () => TestStudentsListBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<MentorEvaluationBloc>(
    () => MentorEvaluationBloc(getIt<MentorRepository>()),
  );
  getIt.registerLazySingleton<FreeTestReviewBloc>(
    () => FreeTestReviewBloc(getIt<MentorRepository>()),
  );
  getIt.registerFactory<AllTestBloc>(
    () => AllTestBloc(getIt<TestRepository>()),
  );
  getIt.registerFactory<MainsTestReviewBloc>(
    () => MainsTestReviewBloc(getIt<TestRepository>()),
  );
  getIt.registerFactory<FetchCourseDetailsBloc>(
    () => FetchCourseDetailsBloc(
      getIt<CourseRepository>(),
      getIt<TestRepository>(),
    ),
  );
  getIt.registerLazySingleton<NotificationBloc>(
    () => NotificationBloc(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(getIt<AnalyticsRepository>()),
  );
}

Future<void> setUpHive() async {
  // Init Hive
  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(TestResultModelAdapter());
  Hive.registerAdapter(DetailedTestResultAdapter());
  Hive.registerAdapter(PrelimsTestProgressAdapter());
  // Open Hive box and register it
  final testResultBox = await Hive.openBox<TestResultModel>('test_results');
  final detailedTestResultBox = await Hive.openBox<DetailedTestResult>(
    'detailed_test_results',
  );
  final prelimsProgressBox = await Hive.openBox<PrelimsTestProgress>(
    'prelims_progress',
  );
  getIt.registerSingleton<Box<TestResultModel>>(testResultBox);
  getIt.registerSingleton<Box<DetailedTestResult>>(detailedTestResultBox);
  getIt.registerSingleton<Box<PrelimsTestProgress>>(prelimsProgressBox);
}
