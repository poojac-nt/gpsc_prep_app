import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AnswerWritingScreen extends StatelessWidget {
  const AnswerWritingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing Practice', style: AppTexts.titleTextStyle),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Writing Practice', style: AppTexts.heading),
                IntrinsicWidth(
                  child: ActionButton(text: 'Start New', onTap: () {}),
                ),
              ],
            ),
            10.hGap,
            TestModule(
              title: 'Daily Practice',
              subtitle: 'Subject Base Daily Writing Prompts',
              prefixIcon: Icons.calendar_today_outlined,
              cards: [
                TestTile(
                  title: 'Good Governance',
                  subtitle: 'General Studies . 250 Words',
                  onTap: () {},
                  buttonTitle: 'Write',
                ),
                10.hGap,
                TestTile(
                  title: 'Economic Reforms',
                  subtitle: 'Current Affairs . 200 Words',
                  onTap: () {},
                  buttonTitle: 'Write',
                ),
              ],
            ),
            10.hGap,
            TestModule(
              title: 'Weekly Practice',
              subtitle: 'Comprehensive Essay Writing',
              prefixIcon: Icons.description_outlined,
              cards: [
                TestTile(
                  title: 'Digital India Initiative',
                  subtitle: 'Essay . 1000 Words',
                  onTap: () {},
                  buttonTitle: 'Write',
                ),
              ],
            ),
            10.hGap,
            TestModule(
              title: 'My Submissions',
              subtitle: 'Track your Submitted Answers',
              prefixIcon: Icons.file_upload_outlined,
              cards: [
                ActionButton(text: 'View All Submissions', onTap: () {}),
                5.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text('5 Pending Reviews'),
                        Text('12 Reviewed'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).padAll(AppPaddings.appPaddingInt),
    );
  }
}
