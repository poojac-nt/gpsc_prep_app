import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/selection_drawer.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/stats_widget.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/test_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../answer_writing/answer_writing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SelectionDrawer(),
      drawerEdgeDragWidth: 150,
      appBar: AppBar(title: Text('Dashboard', style: AppTexts.titleTextStyle)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: AppBorders.borderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back , John Deo',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    5.hGap,
                    Text(
                      'Ready to ace your GPSC exam? Let\'s continue your preparation.',
                      textAlign: TextAlign.left,
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
                  child: BorderedContainer(
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
                  child: BorderedContainer(
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
                  child: BorderedContainer(
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
                  child: BorderedContainer(
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
            BorderedContainer(
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
            BorderedContainer(
              child: TestContainer(
                title: "Daily Test",
                description: "Take today\'s practice test ",
                iconColor: Colors.blue,
                icon: Icons.menu_book,
                buttonTitle: 'Start Test',
                onTap: () => context.push(AppRoutes.mcqTestScreen),
              ),
            ),
            10.hGap,
            BorderedContainer(
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
            BorderedContainer(
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
            BorderedContainer(
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
            BorderedContainer(
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
    );
  }
}
