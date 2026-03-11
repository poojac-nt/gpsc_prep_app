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
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
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
  final int initialIndex;

  const DescriptiveTestScreen({
    super.key,
    required this.descTestModel,
    required this.initialIndex,
  });

  @override
  State<DescriptiveTestScreen> createState() => _DescriptiveTestScreenState();
}

class _DescriptiveTestScreenState extends State<DescriptiveTestScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, AnswerState> _answers = {};
  int currentIndex = 0;
  final FocusNode focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _answers.clear();
    _controller.clear();
    currentIndex = widget.initialIndex;
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _showExitDialog(context);
        if (shouldLeave == true) {
          if (!context.mounted) return;
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text('Descriptive Test', style: AppTexts.titleTextStyle),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<DailyDescTestBloc, DailyDescTestState>(
              listener: (context, state) {
                if (state is DescTestSubmitSuccess) {
                  setState(() {
                    _answers.clear();
                    _controller.clear();
                    currentIndex = 0;
                  });
                  // Reset the bloc state to initial
                  getIt<SnackBarHelper>().showSuccess(state.message);
                  context.pushReplacement(
                    AppRoutes.descriptiveTestResultScreen,
                    extra: widget.descTestModel.name,
                  );
                  context.read<DailyDescTestBloc>().add(ResetDescTestState());
                  context.read<QuestionBloc>().add(ResetQuestionState());
                } else if (state is DescTestSubmitFailed) {
                  getIt<SnackBarHelper>().showError(state.failure.message);
                } else if (state is DailyDescTestMessage) {
                  getIt<SnackBarHelper>().showError(state.message);
                }
              },
            ),
            BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
              listener: (context, state) {
                if (state is PdfDownloadFailure) {
                  getIt<SnackBarHelper>().showError(state.failure.message);
                } else if (state is PdfDownloadSuccess) {
                  getIt<SnackBarHelper>().showSuccess(
                    "Pdf is Saved at :${state.filePath}",
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<QuestionBloc, QuestionState>(
            builder: (context, state) {
              if (state is QuestionLoading) {
                return _buildWhenLoading();
              } else if (state is DescQuestionLoaded) {
                final questions = state.questionsModels;
                final question = questions[currentIndex];
                final answer = _answers[question.id];
                final selectedFile = answer?.files;
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
                            Expanded(child: SizedBox.shrink()),
                            IntrinsicWidth(
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
                                    AppIcons.descPdfDownload,
                                    color: AppColors.primary,
                                    weight: 50.sp,
                                  ),
                                  onPressed: () {
                                    context.read<DownLoadPdfBloc>().add(
                                      DownloadDescTestPdf(
                                        question: question,
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
                            if (question.questionHi?.questionTxt.isNotEmpty ??
                                false) ...[
                              10.hGap,
                              Text(
                                question.questionHi!.questionTxt,
                                style: AppTexts.labelTextStyle,
                              ),
                            ],
                            if (question.questionGj?.questionTxt.isNotEmpty ??
                                false) ...[
                              10.hGap,
                              Text(
                                question.questionGj!.questionTxt,
                                style: AppTexts.labelTextStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                      20.hGap,
                      Text("Your Answer", style: AppTexts.labelTextStyle),
                      20.hGap,
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: AppBorders.borderRadius,
                            ),
                            child: TextField(
                              focusNode: focusNode,
                              maxLines: _controller.text.isEmpty ? 5 : 10,
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
                                    files: [],
                                  );
                                });

                                context.read<DailyDescTestBloc>().add(
                                  AddTextAnswer(
                                    questionId: question.id,
                                    text: value,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 8.h,
                            right: 12.w,
                            child: Text(
                              '${_controller.text.trim().isEmpty ? 0 : _controller.text.trim().split(RegExp(r"\s+")).length} words',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      20.hGap,
                      Text(
                        "Or Upload PDF / Images",
                        style: AppTexts.labelTextStyle,
                      ),
                      20.hGap,
                      if (selectedFile != null) ...[
                        10.hGap,
                        for (var file in selectedFile) ...[
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  file!.path.split('/').last,
                                  style: AppTexts.labelTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    selectedFile.remove(file);
                                    _answers[question.id] = AnswerState(
                                      text: _answers[question.id]?.text ?? '',
                                      files: List.from(selectedFile),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                      ActionButton(
                        text: 'Choose PDF or Images',
                        onTap: () async {
                          // Check if there are already selected files for this question
                          if (_answers[question.id]?.files != null &&
                              _answers[question.id]!.files.isNotEmpty) {
                            final shouldOverwrite = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Overwrite Files?"),
                                    content: const Text(
                                      "You have already selected files. Selecting new files will overwrite the existing ones. Do you want to continue?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: const Text("Overwrite"),
                                      ),
                                    ],
                                  ),
                            );

                            // If user cancels, just return without opening file picker
                            if (shouldOverwrite != true) return;
                          }

                          // Open file picker
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'jpg',
                                  'jpeg',
                                  'png',
                                ],
                                allowMultiple: true,
                              );

                          if (result != null) {
                            final files =
                                result.paths
                                    .where((path) => path != null)
                                    .map((path) => File(path!))
                                    .toList();

                            if (files.isNotEmpty) {
                              setState(() {
                                _answers[question.id] = AnswerState(
                                  text: '',
                                  files: files,
                                );
                                _controller.clear();
                              });

                              // Add files to bloc
                              if (!context.mounted) return;
                              context.read<DailyDescTestBloc>().add(
                                AddFilesAnswer(
                                  questionId: question.id,
                                  files: files,
                                ),
                              );
                            }
                          }
                        },
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
                                        focusNode.unfocus();
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
                                focusNode.unfocus();
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
              return SizedBox.shrink();
            },
          ),
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

  Future<bool?> _showExitDialog(BuildContext context) {
    final hasAnswers = _answers.values.any(
      (answer) => (answer.text.trim().isNotEmpty) || (answer.files.isNotEmpty),
    );

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔔 Top Icon
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 16.h),

                // 📝 Title
                Text(
                  "Exit Test",
                  style: AppTexts.titleTextStyle.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),

                // 💡 Message
                Text(
                  hasAnswers
                      ? "You are leaving the test without submitting answers.\n"
                          "Are you sure you want to discard your answers?"
                      : "Do you want to leave without writing the test ?",
                  style: AppTexts.labelTextStyle.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                10.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Stay
                    IntrinsicWidth(
                      child: ActionButton(
                        text: "Cancel",
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ),
                    hasAnswers
                        ? IntrinsicWidth(
                          child: ActionButton(
                            text: "Submit Test",
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pop(false); // don’t pop screen
                              context.read<DailyDescTestBloc>().add(
                                SubmitDescTest(widget.descTestModel.id),
                              );
                            },
                            backgroundColor: Colors.green,
                          ),
                        )
                        : SizedBox.shrink(),
                    // Leave
                    IntrinsicWidth(
                      child: ActionButton(
                        text: hasAnswers ? "Discard" : "Leave",
                        onTap: () {
                          Navigator.of(context).pop(true);
                        },
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _restoreAnswerForCurrentQuestion(int questionId) {
    final answer = _answers[questionId];
    _controller.text = answer?.text ?? '';
  }
}
