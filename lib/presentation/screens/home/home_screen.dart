import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/selection_drawer.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/stats_widget.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/test_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/connectivity_handler_dialog.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../answer_writing/answer_writing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = getIt<CacheManager>().user;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      await FirebaseMessaging.instance.requestPermission();

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await setFcmToken(fcmToken);
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((payload) {
      final notification = payload.notification;
      if (notification != null) {
        getIt<SnackBarHelper>().showSuccess(notification.body ?? "");
      }
    });
  }

  Future<void> setFcmToken(String fcmToken) async {
    await getIt<SupabaseHelper>().updateOrInsertFcmToken(fcmToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SelectionDrawer(),
      drawerEdgeDragWidth: 150,
      appBar: AppBar(title: Text('Dashboard', style: AppTexts.titleTextStyle)),
      body: BlocListener<ConnectivityBloc, ConnectivityState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is ConnectivityOffline) {
            ConnectivityDialogHelper.showOfflineDialog(context);
          } else if (state is ConnectivityOnline) {
            syncLatestIfExists();
            ConnectivityDialogHelper.dismissDialog(context);
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppBorders.borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back , ${user?.name}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      5.hGap,
                      Text(
                        'Ready to ace your GPSC exam? Let\'s continue your preparation.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              15.hGap,
              Row(
                children: [
                  Expanded(
                    child: ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 15.h,
                      ),
                      child: StatsWidget(
                        text: 'Test taken ',
                        num: '24',
                        icon: Icons.radar,
                        iconColor: Colors.green,
                      ),
                    ),
                  ),
                  10.wGap,
                  Expanded(
                    child: ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 15.h,
                      ),
                      child: StatsWidget(
                        text: 'Avg Score',
                        num: '78%',
                        icon: Icons.score_outlined,
                        iconColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              10.hGap,
              Row(
                children: [
                  Expanded(
                    child: ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 15.h,
                      ),
                      child: StatsWidget(
                        text: 'Study Streak',
                        num: '12 days',
                        icon: Icons.watch_later_outlined,
                        iconColor: Colors.red,
                      ),
                    ),
                  ),
                  10.wGap,
                  Expanded(
                    child: ElevatedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 15.h,
                      ),
                      child: StatsWidget(
                        text: 'Improvement',
                        num: '+15%',
                        icon: Icons.trending_up,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              10.hGap,
              ElevatedContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart),
                        10.wGap,
                        Text(
                          "Performance Overview",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    10.hGap,
                    CustomProgressBar(
                      text: 'General Studies',
                      value: 0.9,
                      percentageText: '90%',
                    ),
                    10.hGap,
                    CustomProgressBar(
                      text: 'Current Affairs',
                      value: 0.6,
                      percentageText: '60%',
                    ),
                    10.hGap,
                    CustomProgressBar(
                      text: 'Reasoning',
                      value: 0.8,
                      percentageText: '80%',
                    ),
                    10.hGap,
                    CustomProgressBar(
                      text: 'Mathematics',
                      value: 0.7,
                      percentageText: '70%',
                    ),
                  ],
                ),
              ),
              10.hGap,
              ElevatedContainer(
                child: TestContainer(
                  title: "Daily Test",
                  description: "Take today's practice test ",
                  iconColor: Colors.blue,
                  icon: Icons.menu_book,
                  buttonTitle: 'Start Test',
                  onTap: () => context.push(AppRoutes.mcqTestScreen),
                ),
              ),
              10.hGap,
              ElevatedContainer(
                child: TestContainer(
                  title: "Custom Test",
                  description: "Create Personalized test ",
                  iconColor: Colors.green,
                  icon: Icons.radar,
                  buttonTitle: 'Create Test',
                  onTap: () {},
                ),
              ),
              10.hGap,
              ElevatedContainer(
                child: TestContainer(
                  title: "Mock Test",
                  description: "Full length practice exam ",
                  iconColor: Colors.purple,
                  icon: Icons.paste_rounded,
                  buttonTitle: 'Take Mock Test',
                  onTap: () {},
                ),
              ),
              10.hGap,
              Text(
                'Answer Writing Practice',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              10.hGap,
              ElevatedContainer(
                child: TestContainer(
                  title: "Daily Writing Practice",
                  description:
                      "Practice descriptive answers and improve overall performance",
                  iconColor: Colors.purple,
                  icon: Icons.menu_book,
                  buttonTitle: 'Start Writing',
                  onTap: () => AnswerWritingScreen(),
                ),
              ),
              10.hGap,
              ElevatedContainer(
                child: TestContainer(
                  title: "My Submission",
                  description: "View submitted answer and feedback",
                  iconColor: Colors.pink,
                  icon: Icons.file_upload_outlined,
                  buttonTitle: 'View Submissions',
                  onTap: () {},
                ),
              ),
            ],
          ).padAll(AppPaddings.defaultPadding),
        ),
      ),
    );
  }

  Future<void> syncLatestIfExists() async {
    final testResultBox = getIt<Box<TestResultModel>>(); // ✅ use getIt
    final latest = testResultBox.get('latest');
    if (latest == null) return;
    final log = getIt<LogHelper>();
    final isOnline =
        context.read<ConnectivityBloc>().state is ConnectivityOnline;
    if (isOnline) {
      try {
        await getIt<SupabaseHelper>().insertDailyTestsResults(latest);
        await testResultBox.delete('latest');
        log.i('✅ Synced test result to Supabase and removed from Hive');
      } catch (e) {
        log.e('❌ Sync failed: $e');
      }
    } else {
      log.e('No Internet');
      return;
    }
  }
}
