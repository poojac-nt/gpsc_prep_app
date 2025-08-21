import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
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
  final Map<int, AnswerState> _answers = {};
  int currentIndex = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _answers.clear();
    _controller.clear();
    currentIndex = 0;
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.descTestModel.id, "en"),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Text('Descriptive Test', style: AppTexts.titleTextStyle),
        ),
      ),
      body: BlocListener<DailyDescTestBloc, DailyDescTestState>(
        listener: (context, state) {
          if (state is DescTestSubmitSuccess) {
            _answers.clear();
            _controller.clear();
            currentIndex = 0;
            getIt<SnackBarHelper>().showSuccess(state.message);
            context.pushReplacement(AppRoutes.descriptiveTestResultScreen);
          } else if (state is DescTestSubmitFailed) {
            getIt<SnackBarHelper>().showError(state.failure.message);
          } else if (state is DailyDescTestMessage) {
            getIt<SnackBarHelper>().showError(state.message);
          } else if (state is PdfDownloadFailure) {
            getIt<SnackBarHelper>().showError(state.failure.message);
          } else if (state is PdfDownloadSuccess) {
            getIt<SnackBarHelper>().showSuccess(
              "Pdf is Save at :${state.filePath}",
            );
          }
        },
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) {
              return _buildWhenLoading();
            } else if (state is DescQuestionLoaded) {
              final questions = state.questionsModels;
              final question = questions[currentIndex];
              final answer = _answers[question.id];
              final selectedFile = answer?.pdf;
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ActionButton(
                              text: "Quit Test",
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => CustomAlertdialog(
                                        title: "Confirm Exit",
                                        mainContent:
                                            "Do you really want to leave the test in between?",
                                        content:
                                            "Your answers so far won’t be saved, you won’t be able to resume this test later.",
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pop(); // Close dialog
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              "Yes, Leave",
                                              style: AppTexts.title.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              context.go(
                                                AppRoutes.studentDashboard,
                                              ); // Close dialog
                                            },
                                          ),
                                        ],
                                      ),
                                );
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Question ${currentIndex + 1}",
                                  style: AppTexts.labelTextStyle.copyWith(
                                    fontSize: 20.sp,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  AppIcons.desc_pdf_download,
                                  color: AppColors.primary,
                                  weight: 50.sp,
                                ),
                                onPressed: () {
                                  context.read<DailyDescTestBloc>().add(
                                    DownloadDescTestPdf(
                                      questionId: question,
                                      index: (currentIndex + 1),
                                      testName: widget.descTestModel.name,
                                    ),
                                  );
                                },
                              ),
                            ],
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
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type your answer here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10.w),
                        ),
                        onChanged: (value) {
                          setState(() {
                            // Clear PDF when typing
                            _answers[question.id] = AnswerState(
                              text: value,
                              pdf: null,
                            );
                          });

                          context.read<DailyDescTestBloc>().add(
                            AddTextAnswer(questionId: question.id, text: value),
                          );
                        },
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
                                  "Upload PDF for this question",
                                  style: AppTexts.labelTextStyle,
                                ),
                                10.hGap,
                                if (selectedFile != null) ...[
                                  10.hGap,
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedFile.path.split('/').last,
                                          style: AppTexts.labelTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _answers[question.id] = AnswerState(
                                              text: '',
                                              pdf: null,
                                            );
                                            _controller
                                                .clear(); // clear TextField too
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                                10.hGap,
                                ActionButton(
                                  text: 'Choose PDF',
                                  onTap: () async {
                                    FilePickerResult? result = await FilePicker
                                        .platform
                                        .pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );

                                    if (result != null &&
                                        result.files.single.path != null) {
                                      final file = File(
                                        result.files.single.path!,
                                      );

                                      setState(() {
                                        // Clear text when PDF selected
                                        _answers[question.id] = AnswerState(
                                          text: '',
                                          pdf: file,
                                        );
                                        _controller.clear(); // clear TextField
                                      });

                                      context.read<DailyDescTestBloc>().add(
                                        AddPdfAnswer(
                                          questionId: question.id,
                                          file: file,
                                        ),
                                      );
                                    }
                                  },
                                ),
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
                            isLoading: (currentIndex == 0),
                            onTap:
                                currentIndex == 0
                                    ? () {}
                                    : () {
                                      setState(() {
                                        currentIndex--;
                                        _restoreAnswerForCurrentQuestion(
                                          state
                                              .questionsModels[currentIndex]
                                              .id,
                                        );
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
                                  _restoreAnswerForCurrentQuestion(
                                    state.questionsModels[currentIndex].id,
                                  );
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
          mainContent: "You have attempted some questions.",
          content: "Are you sure you want to submit the test?",
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop();
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
                context.pop();
                context.read<DailyDescTestBloc>().add(
                  SubmitDescTest(widget.descTestModel.id),
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

  void _restoreAnswerForCurrentQuestion(int questionId) {
    final answer = _answers[questionId];
    _controller.text = answer?.text ?? '';
  }
}
