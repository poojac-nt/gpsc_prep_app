import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/bloc/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/bloc/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../widgets/bordered_container.dart';
import '../descriptive_test_module/bloc/daily_descriptive_test_state.dart';

class AnswerWritingScreen extends StatefulWidget {
  const AnswerWritingScreen({super.key});

  @override
  State<AnswerWritingScreen> createState() => _AnswerWritingScreenState();
}

class _AnswerWritingScreenState extends State<AnswerWritingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<DailyDescTestBloc>().add(FetchAllTests());
  }

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
      body: BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
        builder: (context, state) {
          if (state is DailyDescTestFetching) {
            return Center(child: _buildWhenLoading());
          }
          if (state is DailyDescTestFetchFailed) {
            return Center(child: Text(state.failure.toString()));
          }
          if (state is DailyDescTestFetched) {
            final descTests = state.dailyTestModel;
            return SingleChildScrollView(
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
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: descTests.length,
                    itemBuilder: (context, index) {
                      return TestModule(
                        title: "Daily Practice",
                        subtitle: "Subject based Daily test",
                        prefixIcon: Icons.calendar_today_outlined,
                        cards: [
                          TestTile(
                            title: descTests[index].name,
                            subtitle:
                                '${descTests[index].noQuestions.toString()} Questions · ${descTests[index].duration.toString()} Mins',
                            onTap: () {
                              context.pushReplacement(
                                AppRoutes.descriptiveTestInstructionScreen,
                              );
                            },
                            buttonTitle: 'Write',
                          ),
                        ],
                      ).padSymmetric(vertical: 6.h);
                    },
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
            ).padAll(AppPaddings.appPaddingInt);
          }
          return Container();
        },
      ),
    );
  }

  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.appPaddingInt),
      child: Skeletonizer(
        enabled: true, // Set this to false when actual data is loaded
        child: SingleChildScrollView(
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

              /// Daily Tests Section
              TestModule(
                title: "Daily Tests",
                subtitle: "Subject-based Daily Practice",
                prefixIcon: Icons.calendar_today_outlined,
                cards: List.generate(
                  3,
                  (index) => TestTile(
                    title: "Loading Test $index",
                    subtitle: "00 Questions · 0 min",
                    onTap: () {},
                    buttonTitle: 'Start',
                  ).padSymmetric(vertical: 6.h),
                ),
              ),
              10.hGap,

              /// Mock Tests Section
              TestModule(
                title: "Mock Tests",
                subtitle: "Full Length Practice Exams",
                prefixIcon: Icons.description_outlined,
                cards: [
                  TestTile(
                    title: "GPSC Mock Test #1",
                    subtitle: "100 Questions · 2 hours",
                    widgets: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.accentColor,
                            width: 1,
                          ),
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

              /// Offline Mode Section
              TestModule(
                title: 'Offline Mode',
                subtitle: 'Download tests for offline Practice',
                prefixIcon: Icons.file_download_outlined,
                cards: [
                  BorderedContainer(
                    borderColor: AppColors.accentColor,
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
                    borderColor: AppColors.accentColor,
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
      ),
    );
  }
}
