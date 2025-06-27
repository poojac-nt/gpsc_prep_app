import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MCQTestScreen extends StatelessWidget {
  const MCQTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MCQ Tests", style: AppTexts.titleTextStyle),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(CupertinoIcons.bell_fill, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Tests', style: AppTexts.heading),
                IntrinsicWidth(
                  child: ActionButton(text: 'Generate Test', onTap: () {}),
                ),
              ],
            ),
            10.hGap,
            // Daily Tests Section
            TestModule(
              title: "Daily Tests",
              subtitle: "Subject-based Daily Practice",
              icon: Icons.calendar_today_outlined,
              cards: [
                TestTile(
                  title: "General Studies",
                  subtitle: "20 Questions . 30 min",
                  onTap: () => context.push(AppRoutes.testInstructionScreen),
                  buttonTitle: 'Start',
                ),
                10.hGap,
                TestTile(
                  title: "Current Affairs",
                  subtitle: "20 Questions . 30 min",
                  onTap: () => context.push(AppRoutes.testInstructionScreen),
                  buttonTitle: 'Start',
                ),
              ],
            ),
            10.hGap,
            // Mock Tests Section
            TestModule(
              title: "Mock Tests",
              subtitle: "Full Length practice Exams",
              icon: Icons.description_outlined,
              cards: [
                TestTile(
                  title: "GPSC Mock Test #1",
                  subtitle: "100 Questions . 2 hours",
                  widgets: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.file_download_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ],
                  onTap: () {},
                  buttonTitle: 'Start',
                ),
              ],
            ),
            10.hGap,
            TestModule(
              title: 'Offline Mode',
              subtitle: 'Download tests for offline Practice',
              icon: Icons.file_download_outlined,
              cards: [
                BorderedContainer(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_download_outlined),
                      10.wGap,
                      Text('Download PDF Test', style: AppTexts.title),
                    ],
                  ),
                ),
                10.hGap,
                BorderedContainer(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload_outlined),
                      10.wGap,
                      Text('Upload Answers', style: AppTexts.title),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ).padAll(AppPaddings.appPaddingInt),
      ),
    );
  }
}
