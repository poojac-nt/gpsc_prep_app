import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/extensions/padding.dart';
import '../../blocs/question/question_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/utils/services/ad_service.dart';

class OMRScreen extends StatefulWidget {
  const OMRScreen({super.key, required this.testModel, this.language});
  final TestModel testModel;
  final String? language;

  @override
  State<OMRScreen> createState() => _OMRScreenState();
}

class _OMRScreenState extends State<OMRScreen> {
  int _currentPage = 0;
  final int _questionsPerPage = 50;
  late final int _totalPages;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _totalPages = (widget.testModel.noQuestions / _questionsPerPage).ceil();
    context.read<QuestionBloc>().add(
      LoadMcqQuestion(widget.testModel.id, widget.language),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage == _totalPages - 1;

    return BlocListener<TestCubit, TestCubitSubmitted>(
      listener: (context, state) {
        context.read<TestBloc>().add(
          SubmitTest(
            widget.testModel.id,
            state.questions,
            state.selectedOption,
            state.answeredStatus,
            state.totalQuestions,
            state.correctAnswers,
            state.inCorrectAnswers,
            state.attemptedQuestions,
            state.notAttemptedQuestions,
            state.score,
            state.timeSpent,
            state.batchResults,
          ),
        );
        Environment.isDevelopment ? null : AdService().showInterstitialAd();
        context.pushReplacement(
          AppRoutes.resultScreen,
          extra: ResultScreenArgs(
            isFromTest: true,
            testModal: widget.testModel,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("OMR Screen"),
          actionsPadding: EdgeInsets.all(10),
          actions: [
            BlocBuilder<QuestionCubit, QuestionCubitState>(
              builder: (context, state) {
                int attemptedCount = 0;
                if (state is McqQuestionCubitLoaded) {
                  attemptedCount = state.answeredStatus.where((e) => e).length;
                }
                return Text(
                  "Attempted: $attemptedCount/${widget.testModel.noQuestions}",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state is McqQuestionLoaded && !_initialized) {
              _initialized = true;
              context.read<QuestionCubit>()
                ..reset()
                ..initialize(
                  state.questions,
                  state.questionsModels,
                  widget.language ?? 'en',
                );
            }
          },
          builder: (context, questionBlocState) {
            if (questionBlocState is QuestionLoading) {
              return _buildSkeleton();
            } else if (questionBlocState is McqQuestionLoaded) {
              return BlocBuilder<QuestionCubit, QuestionCubitState>(
                builder: (context, questionCubitState) {
                  if (questionCubitState is! McqQuestionCubitLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        decoration: const BoxDecoration(
                          color: Color(0xffF1F5F9),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.blueGrey,
                              width: 0.67,
                            ),
                            top: BorderSide(
                              color: Colors.blueGrey,
                              width: 0.67,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "Q.No.")),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "A")),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "B")),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "C")),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "D")),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(child: TopLabelRow(text: "E")),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: ListView.builder(
                          itemCount: _questionsPerPage,
                          itemBuilder: (context, index) {
                            final int globalIndex =
                                (_currentPage * _questionsPerPage) + index;
                            // Check if we have valid data for this index
                            if (globalIndex >=
                                questionBlocState.questionsModels.length) {
                              return const SizedBox.shrink();
                            }

                            final displayQuestionNumber = globalIndex + 1;
                            // Use selectedOption from Cubit
                            // The list in Cubit corresponds to questions list
                            final selectedOption =
                                questionCubitState.selectedOption[globalIndex];

                            return Container(
                              color:
                                  index % 2 == 0
                                      ? Colors.white
                                      : const Color(0xffFBFCFD),
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        displayQuestionNumber
                                            .toString()
                                            .padLeft(3, '0'),
                                        style: const TextStyle(
                                          color: Color(0xff64748B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...['A', 'B', 'C', 'D', 'E'].map(
                                    (option) => Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: RadioContainer(
                                          text: option,
                                          isSelected: selectedOption == option,
                                          onTap: () {
                                            if (selectedOption == option) {
                                              context
                                                  .read<QuestionCubit>()
                                                  .answerQuestionAt(
                                                    globalIndex,
                                                    null,
                                                  );
                                            } else {
                                              context
                                                  .read<QuestionCubit>()
                                                  .answerQuestionAt(
                                                    globalIndex,
                                                    option,
                                                  );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: ActionButton(
                                text: "Prev",
                                onTap:
                                    isFirstPage
                                        ? () {} // Disable button on the first page
                                        : () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        },
                                fontColor: Colors.white,
                                backgroundColor:
                                    isFirstPage
                                        ? Colors.grey
                                        : AppColors.primary,
                              ),
                            ),
                            30.wGap,
                            Expanded(
                              child: ActionButton(
                                text: isLastPage ? "Submit" : "Next",
                                onTap: () {
                                  if (isLastPage) {
                                    context
                                        .read<TestCubit>()
                                        .calculateAndEmitTestResult(
                                          testId: widget.testModel.id,
                                          questionsModel:
                                              questionBlocState.questionsModels,
                                          questions:
                                              questionBlocState.questions,
                                          selectedOption:
                                              questionCubitState.selectedOption,
                                          answeredStatus:
                                              questionCubitState.answeredStatus,
                                          marks: questionBlocState.marks,
                                          minSpent: 0,
                                          secSpent: 0,
                                          languageCode: widget.language ?? 'en',
                                        );
                                  } else {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                },
                                fontColor: Colors.white,
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ).padSymmetric(horizontal: 10.w),
                      ),
                    ],
                  );
                },
              );
            } else if (questionBlocState is QuestionLoadFailed) {
              return Center(
                child: Text("Error: ${questionBlocState.failure.message}"),
              );
            }
            return const Center(child: Text("Initializing..."));
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            decoration: const BoxDecoration(
              color: Color(0xffF1F5F9),
              border: Border(
                bottom: BorderSide(color: Colors.blueGrey, width: 0.67),
                top: BorderSide(color: Colors.blueGrey, width: 0.67),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(child: TopLabelRow(text: "Q.No.")),
                ),
                Expanded(flex: 1, child: Center(child: TopLabelRow(text: "A"))),
                Expanded(flex: 1, child: Center(child: TopLabelRow(text: "B"))),
                Expanded(flex: 1, child: Center(child: TopLabelRow(text: "C"))),
                Expanded(flex: 1, child: Center(child: TopLabelRow(text: "D"))),
                Expanded(flex: 1, child: Center(child: TopLabelRow(text: "E"))),
              ],
            ),
          ),
          Expanded(
            flex: 10,
            child: ListView.builder(
              itemCount: 15, // Dummy count for skeleton
              itemBuilder: (context, index) {
                return Container(
                  color:
                      index % 2 == 0 ? Colors.white : const Color(0xffFBFCFD),
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "000",
                            style: const TextStyle(
                              color: Color(0xff64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      ...['A', 'B', 'C', 'D', 'E'].map(
                        (option) => Expanded(
                          flex: 1,
                          child: Center(
                            child: RadioContainer(
                              text: option,
                              isSelected: false,
                              onTap: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ActionButton(
                    text: "Prev",
                    onTap: () {},
                    fontColor: Colors.white,
                    backgroundColor: Colors.grey,
                  ),
                ),
                30.wGap,
                Expanded(
                  child: ActionButton(
                    text: "Next",
                    onTap: () {},
                    fontColor: Colors.white,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ).padSymmetric(horizontal: 10.w),
          ),
        ],
      ),
    );
  }
}

class TopLabelRow extends StatelessWidget {
  final String text;

  const TopLabelRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xff64748B),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class RadioContainer extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const RadioContainer({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.transparent,
          border:
              isSelected
                  ? null
                  : Border.all(color: const Color(0xffD1D9E4), width: 1.5),
        ),
        child:
            isSelected
                ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ) // No text when selected, to show a solid circle
                : Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xff64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
      ),
    );
  }
}
