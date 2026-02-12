import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/study_material/study_material_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ReviewQuestionUploadScreen extends StatefulWidget {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;
  final bool isFromStudyMaterial;
  final String? title;
  final String? url;
  final String? language;

  const ReviewQuestionUploadScreen({
    super.key,
    required this.payload,
    required this.isTestUpload,
    required this.isFromStudyMaterial,
    this.title,
    this.url,
    this.language,
  });

  @override
  State<ReviewQuestionUploadScreen> createState() =>
      _ReviewQuestionUploadScreenState();
}

class _ReviewQuestionUploadScreenState
    extends State<ReviewQuestionUploadScreen> {
  bool isLater = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // If today is selected, ensure time is not in the past
        final now = DateTime.now();
        final isToday =
            selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day;
        if (isToday && !_isTimeAfterNow(selectedTime)) {
          selectedTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    // Create a DateTime from selectedDate and current selectedTime
    DateTime initialDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // If today is selected and initial time is in the past, reset to now plus buffer
    if (isToday && initialDateTime.isBefore(now)) {
      initialDateTime = now.add(const Duration(minutes: 1));
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 250.h,
            padding: const EdgeInsets.only(top: 6.0),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Select Time',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialDateTime,
                    minimumDate:
                        isToday
                            ? DateTime(
                              now.year,
                              now.month,
                              now.day,
                              now.hour,
                              now.minute,
                            )
                            : null,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        selectedTime = TimeOfDay.fromDateTime(newDateTime);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  bool _isTimeAfterNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    return time.hour > now.hour ||
        (time.hour == now.hour && time.minute > now.minute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<UploadQuestionsBloc>(),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          extendBody: true,
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            title: Text(
              'Review Questions',
              style: AppTexts.titleTextStyle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: BlocListener<StudyMaterialBloc, StudyMaterialState>(
            listener: (context, state) {
              if (state is StudyMaterialAdded) {
                context.pop();
                getIt<SnackBarHelper>().showSuccess(
                  '✅ Study Material uploaded successfully.',
                );
              } else if (state is StudyMaterialError) {
                getIt<SnackBarHelper>().showError(state.failure.message);
              }
            },
            child: BlocConsumer<UploadQuestionsBloc, UploadQuestionsState>(
              listener: (context, state) {
                if (state is UploadFileSuccess) {
                  context.pushReplacement(AppRoutes.studentDashboard);
                  getIt<SnackBarHelper>().showSuccess(
                    '✅ Uploaded: ${state.result.successCount}, '
                    'Duplicates: ${state.result.duplicateCount}, '
                    'Failed: ${state.result.failCount}',
                  );
                } else if (state is UploadFileFailure) {
                  getIt<SnackBarHelper>().showError(state.errorMessage);
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    _buildNotifyUserRow(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.payload.length,
                        itemBuilder: (context, index) {
                          final question = widget.payload[index];
                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  12.hGap,
                                  Builder(
                                    builder: (context) {
                                      final data =
                                          (question['languages']
                                              as Map<String, dynamic>)['en'];
                                      if (data == null) {
                                        return const Text(
                                          'No English content available.',
                                        );
                                      }
                                      final correctAnswer =
                                          data['correct_answer']; // e.g., "option_c"

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildDetailRow(
                                            Icons.subject,
                                            'Subject',
                                            question['subject_name'],
                                          ),
                                          _buildDetailRow(
                                            Icons.topic,
                                            'Topic',
                                            question['topic_name'],
                                          ),
                                          _buildDetailRow(
                                            Icons.quiz,
                                            'Test Type',
                                            question['test_type'],
                                          ),
                                          _buildDetailRow(
                                            Icons.category,
                                            'Question Type',
                                            question['question_type'],
                                          ),
                                          _buildDetailRow(
                                            Icons.star,
                                            'Mark',
                                            question['marks'].toString(),
                                          ),
                                          _buildDetailRow(
                                            Icons.assignment,
                                            'Test Name',
                                            question['test_name'],
                                          ),

                                          15.hGap,
                                          Divider(color: Colors.grey.shade100),
                                          10.hGap,
                                          // Question text
                                          MarkdownWidget(
                                            data: data['question_txt'] ?? '',
                                            shrinkWrap: true,
                                            config: MarkdownConfig(
                                              configs: [
                                                PConfig(
                                                  textStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          15.hGap,
                                          // Options A-D
                                          ...['a', 'b', 'c', 'd'].map((opt) {
                                            final key = 'option_$opt';
                                            final value = data['opt_$opt'];
                                            final isCorrect =
                                                key == correctAnswer;
                                            return Container(
                                              width: double.infinity,
                                              margin: EdgeInsets.only(
                                                bottom: 8.h,
                                              ),
                                              padding: EdgeInsets.all(12.sp),
                                              decoration: BoxDecoration(
                                                color:
                                                    isCorrect
                                                        ? Colors.green.shade50
                                                        : Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                  color:
                                                      isCorrect
                                                          ? Colors.green
                                                              .withAlpha(100)
                                                          : Colors
                                                              .grey
                                                              .shade200,
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${opt.toUpperCase()}. ',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          isCorrect
                                                              ? Colors.green
                                                              : Colors.black87,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      value ?? '',
                                                      style: TextStyle(
                                                        color:
                                                            isCorrect
                                                                ? Colors
                                                                    .green
                                                                    .shade700
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            isCorrect
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isCorrect)
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                ],
                                              ),
                                            );
                                          }),

                                          // Explanation
                                          if ((data['explanation'] ?? '')
                                              .toString()
                                              .trim()
                                              .isNotEmpty)
                                            Container(
                                              margin: EdgeInsets.only(top: 8.h),
                                              padding: EdgeInsets.all(12.sp),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.lightbulb,
                                                        size: 18.sp,
                                                        color: Colors.blue,
                                                      ),
                                                      5.wGap,
                                                      const Text(
                                                        'Explanation',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  8.hGap,
                                                  MarkdownWidget(
                                                    data: data['explanation'],
                                                    shrinkWrap: true,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar:
              BlocBuilder<UploadQuestionsBloc, UploadQuestionsState>(
                builder: (context, state) {
                  final isUploading = state is UploadFileInProgress;
                  final uploadResult =
                      state is UploadFileSuccess ? state.result : null;

                  return Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (uploadResult != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Text(
                              '✅ Uploaded: ${uploadResult.successCount}, '
                              'Duplicates: ${uploadResult.duplicateCount}, '
                              'Failed: ${uploadResult.failCount}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        IntrinsicWidth(
                          child: ActionButton(
                            isLoading: isUploading,
                            onTap: () {
                              DateTime? availableAt;
                              if (isLater) {
                                availableAt =
                                    DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      selectedTime.hour,
                                      selectedTime.minute,
                                    ).toUtc();
                              } else {
                                availableAt = DateTime.now().toUtc();
                              }

                              widget.isFromStudyMaterial
                                  ? context.read<StudyMaterialBloc>().add(
                                    UploadStudyMaterialWithTest(
                                      title: widget.title!,
                                      url: widget.url!,
                                      language: widget.language!,
                                      payload: widget.payload,
                                    ),
                                  )
                                  : context.read<UploadQuestionsBloc>().add(
                                    McqUploadParsedQuestions(
                                      payload: widget.payload,
                                      isTestUpload: widget.isTestUpload,
                                      availableAt: availableAt,
                                    ),
                                  );
                            },
                            text: 'Confirm & Upload',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildNotifyUserRow() {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 0.h, bottom: 10.h),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Notify User',
                style: AppTexts.labelTextStyle.copyWith(fontSize: 16.sp),
              ),
              const Spacer(),
              _buildToggleButton(
                'Immediate',
                !isLater,
                () => setState(() => isLater = false),
              ),
              8.wGap,
              _buildToggleButton(
                'Later',
                isLater,
                () => setState(() => isLater = true),
              ),
            ],
          ),
          if (isLater) ...[
            15.hGap,
            Row(
              children: [
                Expanded(
                  child: _buildPickerTile(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy').format(selectedDate),
                    onTap: () => _selectDate(context),
                  ),
                ),
                12.wGap,
                Expanded(
                  child: _buildPickerTile(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: selectedTime.format(context),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primary),
            10.wGap,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey),
          6.wGap,
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
