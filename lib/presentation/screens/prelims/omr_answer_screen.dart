import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../../core/di/di.dart';
import '../../../core/helpers/log_helper.dart';
import '../../../utils/extensions/padding.dart';
import '../../blocs/timer/timer_bloc.dart';
import '../../blocs/timer/timer_event.dart';
import '../../blocs/timer/timer_state.dart';
import '../../widgets/custom_alertdialog.dart';

class OMRScreen extends StatefulWidget {
  const OMRScreen({super.key});

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
    _totalPages = (_totalQuestions / _questionsPerPage).ceil();
    context.read<TimerBloc>().add(TimerStart(testDuration: 10));
  }

  int get _attemptedCount =>
      _selectedAnswers.values.where((answer) => answer != null).length;

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("OMR Screen"),
                Text(
                  "Attempted: $_attemptedCount/$_totalQuestions",
                  // Updated counter
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 18.sp),
                  5.wGap,
                  BlocBuilder<TimerBloc, TimerState>(
                    builder: (context, state) {
                      if (state is TimerRunning) {
                        return SizedBox(
                          width: 43.w,
                          child: Text(
                            "${state.remainingMinutes.toString().padLeft(2, '0')}:${state.remainingSeconds.toString().padLeft(2, '0')}",
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        );
                      }
                      if (state is TimerStopped) {
                        getIt<LogHelper>().w(state.totalMins.toString());
                        getIt<LogHelper>().w(state.totalSecs.toString());
                        return SizedBox.shrink();
                      }
                      return Text('00:00');
                    },
                  ),
                ],
              ),
            ).padSymmetric(horizontal: 10.w),
          ],
        ),
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

  void _buildAutoSubmitDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final total = 10;
        final attempted = 5;
        return CustomAlertdialog(
          title: "Time is over",
          mainContent: "You have attempted $attempted out of $total questions.",
          content:
              'Your time for this test has ended. Submitting your answers now and showing your results.',
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "View Result",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
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
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.all(10),
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
