import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DescriptiveAnswersScreen extends StatefulWidget {
  final DescTestModel descTestModel;

  const DescriptiveAnswersScreen({super.key, required this.descTestModel});

  @override
  State<DescriptiveAnswersScreen> createState() =>
      _DescriptiveAnswersScreenState();
}

class _DescriptiveAnswersScreenState extends State<DescriptiveAnswersScreen> {
  final ScrollController _scrollController = ScrollController();
  int currentIndex = 0;

  @override
  void initState() {
    currentIndex = 0;
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.descTestModel.id, "en"),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descriptive Answers', style: AppTexts.titleTextStyle),
      ),
      body: BlocBuilder<QuestionBloc, QuestionState>(
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
                    labelText: "",
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
                        15.hGap,
                        MarkdownWidget(
                          data: question.questionEn.answerTxt,
                          shrinkWrap: true,
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
                          isLoading: (currentIndex == 0),
                          onTap:
                              currentIndex == 0
                                  ? () {}
                                  : () {
                                    setState(() {
                                      currentIndex--;
                                    });
                                    goTop();
                                  },
                          fontColor: Colors.white,
                        ),
                      ),
                      150.wGap,
                      Expanded(
                        child: ActionButton(
                          isLoading: (currentIndex == questions.length - 1),
                          text: "Next",
                          backgroundColor: AppColors.primary,
                          onTap: () {
                            if (currentIndex < questions.length - 1) {
                              setState(() {
                                currentIndex++;
                              });
                              goTop();
                            }
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
              child: Text('Failed to load questions: ${state.failure.message}'),
            );
          }
          return Center(child: Text('No Questions Available'));
        },
      ),
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
            CustomProgressBar(
              titleText: "Question 1 of 10",
              value: 0.1,
              labelText: "0 Answered",
            ),
            20.hGap,
            TestModule(
              title: "Question 1",
              cards: [
                Text("This is a sample question text."),
                10.hGap,
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

  void goTop() {
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }
}
