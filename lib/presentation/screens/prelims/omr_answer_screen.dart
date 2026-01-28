import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../../core/di/di.dart';
import '../../../core/helpers/log_helper.dart';
import '../../../utils/extensions/padding.dart';
import '../../blocs/question/question_bloc.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer/timer_event.dart';
import '../../blocs/timer/timer_state.dart';
import '../../widgets/custom_alertdialog.dart';

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
  final int _totalQuestions = 200;
  late final int _totalPages;

  // State map to store selected answers [questionNumber: selectedOption]
  final Map<int, String?> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _totalPages = (widget.testModel.noQuestions / _questionsPerPage).ceil();
    context.read<QuestionBloc>().add(
      LoadMcqQuestion(widget.testModel.id, widget.language),
    );
  }

  int get _attemptedCount =>
      _selectedAnswers.values.where((answer) => answer != null).length;

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("OMR Screen"),
        actionsPadding: EdgeInsets.all(10),
        actions: [
          Text(
            "Attempted: $_attemptedCount/${widget.testModel.noQuestions}",
            style: TextStyle(fontSize: 12.sp, color: Colors.black54),
          ),
        ],
      ),
      body: Column(
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
              itemCount: _questionsPerPage,
              itemBuilder: (context, index) {
                final questionNumber =
                    (_currentPage * _questionsPerPage) + index + 1;
                final selectedOption = _selectedAnswers[questionNumber];
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
                            questionNumber.toString().padLeft(3, '0'),
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
                                setState(() {
                                  if (selectedOption == option) {
                                    _selectedAnswers[questionNumber] = null;
                                  } else {
                                    _selectedAnswers[questionNumber] = option;
                                  }
                                });
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
                        isFirstPage ? Colors.grey : AppColors.primary,
                  ),
                ),
                30.wGap,
                Expanded(
                  child: ActionButton(
                    text: isLastPage ? "Submit" : "Next",
                    onTap: () {
                      if (isLastPage) {
                        // Handle submit logic
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
