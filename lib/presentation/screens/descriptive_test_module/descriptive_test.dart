import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_alertdialog.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../widgets/action_button.dart';
import '../../widgets/bordered_container.dart';
import '../dashboard/widgets/custom_progress_bar.dart';

class DescriptiveTestScreen extends StatefulWidget {
  final DescTestModel descTestModel;

  const DescriptiveTestScreen({super.key, required this.descTestModel});

  @override
  State<DescriptiveTestScreen> createState() => _DescriptiveTestScreenState();
}

class _DescriptiveTestScreenState extends State<DescriptiveTestScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.descTestModel.id, "en"),
    );
    super.initState();
  }

  int currentIndex = 0;
  Map<int, String> answers = {};
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descriptive Test', style: AppTexts.titleTextStyle),
      ),
      body: BlocListener<DailyDescTestBloc, DailyDescTestState>(
        listener: (context, state) {
          if (state is DescTestSubmitSuccess) {
            getIt<SnackBarHelper>().showSuccess(state.message);
            context.pushReplacement(AppRoutes.descriptiveTestResultScreen);
          } else if (state is DescTestSubmitFailed) {
            getIt<SnackBarHelper>().showError(state.failure.message);
          }
        },
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) {
              return _buildWhenLoading();
            } else if (state is DescQuestionLoaded) {
              final questions = state.questionsModels;
              final question = questions[currentIndex];
              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomProgressBar(
                      titleText:
                          "Question ${currentIndex + 1} of ${questions.length}",
                      value: (currentIndex + 1) / questions.length,
                      labelText: "$currentIndex Answered",
                    ),
                    20.hGap,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ActionButton(
                              text: "Quit Test",
                              onTap: () {
                                context.go(AppRoutes.studentDashboard);
                              },
                            ),
                          ),
                          100.wGap,
                          Expanded(
                            child: ActionButton(
                              text: "Submit Test",
                              onTap: () {
                                _buildSubmitDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: AppBorders.borderRadius,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question ${currentIndex + 1}",
                            style: AppTexts.labelTextStyle.copyWith(
                              fontSize: 20.sp,
                            ),
                          ),
                          15.hGap,
                          Text(
                            question.questionEn.questionTxt,
                            style: AppTexts.labelTextStyle,
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    Text("Your Answer", style: AppTexts.labelTextStyle),
                    20.hGap,
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: AppBorders.borderRadius,
                      ),
                      child: TextField(
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: "Type your answer here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10.w),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppBorders.borderRadius,
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          answers[question.id] = value;
                        },
                        controller: _controller,
                      ),
                    ),
                    20.hGap,
                    Text(
                      "Or Upload PDF Answer",
                      style: AppTexts.labelTextStyle,
                    ),
                    20.hGap,
                    BorderedContainer(
                      borderColor: Colors.grey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: Colors.grey.shade600,
                                  size: 80.sp,
                                ),
                                Text(
                                  "Upload PDF for this questions",
                                  style: AppTexts.labelTextStyle,
                                ),
                                10.hGap,
                                ActionButton(text: 'Choose PDF', onTap: () {}),
                                10.hGap,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ActionButton(
                            backgroundColor: AppColors.primary,
                            text: "Previous",
                            isLoading: (currentIndex == 0) ? true : false,
                            onTap:
                                currentIndex == 0
                                    ? () {}
                                    : () {
                                      setState(() {
                                        currentIndex--;
                                        final prevQuestion =
                                            questions[currentIndex];
                                        _controller.text =
                                            answers[prevQuestion.id] ?? '';
                                      });
                                      goTop();
                                    },
                            fontColor: Colors.white,
                          ),
                        ),
                        150.wGap,
                        Expanded(
                          child: ActionButton(
                            isLoading:
                                (currentIndex == questions.length - 1)
                                    ? true
                                    : false,
                            text: "Next",
                            backgroundColor: AppColors.primary,
                            onTap: () {
                              if (currentIndex < state.questions.length - 1) {
                                setState(() {
                                  currentIndex++;
                                  final nextQuestion = questions[currentIndex];
                                  _controller.text =
                                      answers[nextQuestion.id] ?? '';
                                });
                              }
                              goTop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ).padAll(AppPaddings.defaultPadding),
              );
            } else if (state is QuestionLoadFailed) {
              return Center(
                child: Text(
                  'Failed to load questions: ${state.failure.message}',
                ),
              );
            }
            return Center(child: Text('No Questions Available'));
          },
        ),
      ),
    );
  }

  void goTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _buildSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertdialog(
          title: "Submit Test",
          mainContent: "You have attempted  out of  questions.",
          content: "Are you sure you want to submit the test?",
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Submit",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop(); // close dialog
                context.read<DailyDescTestBloc>().add(
                  SubmitDescTest(answers, widget.descTestModel.id),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.defaultPadding),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake progress bar
            CustomProgressBar(
              titleText: "Question 1 of 10",
              value: 0.1,
              labelText: "0 Answered",
            ),
            20.hGap,
            // Question Title
            TestModule(
              title: "Question 1",
              cards: [
                // Fake question
                Text("This is a sample question text."),
                10.hGap,
                // Fake options
                Column(
                  children: List.generate(4, (index) {
                    return BorderedContainer(
                      padding: EdgeInsets.zero,
                      radius: BorderRadius.circular(10),
                      borderColor: AppColors.accentColor,
                      child: RadioListTile<String>(
                        value: 'Option $index',
                        groupValue: null,
                        onChanged: null,
                        title: Text("Option $index"),
                      ),
                    ).padAll(5);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
