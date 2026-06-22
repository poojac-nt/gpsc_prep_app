import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/notify_user_timing_widget.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:markdown_widget/markdown_widget.dart';

class DescReviewQuestionUploadScreen extends StatefulWidget {
  final List<Map<String, dynamic>> payload;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  const DescReviewQuestionUploadScreen({
    super.key,
    required this.payload,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });

  @override
  State<DescReviewQuestionUploadScreen> createState() =>
      _DescReviewQuestionUploadScreenState();
}

class _DescReviewQuestionUploadScreenState
    extends State<DescReviewQuestionUploadScreen> {
  late final NotifyUserTimingController _timingController;

  @override
  void initState() {
    super.initState();
    _timingController = NotifyUserTimingController();
  }

  @override
  void dispose() {
    _timingController.dispose();
    super.dispose();
  }

  void _showLanguageSelectionBottomSheet(BuildContext context) {
    final Set<String> detectedCodes = {};
    for (final q in widget.payload) {
      if (q['languages'] is Map) {
        detectedCodes.addAll((q['languages'] as Map).keys.cast<String>());
      }
    }

    if (detectedCodes.isEmpty) {
      _dispatchUpload([]);
      return;
    }

    final Map<String, String> langMap = {
      'en': 'English',
      'hi': 'Hindi',
      'gj': 'Gujarati',
      'gu': 'Gujarati',
    };

    final List<String> availableCodes = detectedCodes.toList();
    List<String> selectedCodes = List.from(availableCodes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Display Languages',
                      style: AppTexts.heading.copyWith(fontSize: 18.sp),
                    ),
                    10.hGap,
                    Text(
                      'Choose which languages should be available to students for this test.',
                      style: AppTexts.subTitle.copyWith(fontSize: 13.sp, color: AppColors.gray500),
                    ),
                    20.hGap,
                    ...availableCodes.map((code) {
                      final displayName = langMap[code.toLowerCase()] ?? code.toUpperCase();
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(displayName),
                        value: selectedCodes.contains(code),
                        activeColor: AppColors.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedCodes.add(code);
                            } else {
                              selectedCodes.remove(code);
                            }
                          });
                        },
                      );
                    }),
                    20.hGap,
                    SizedBox(
                      width: double.infinity,
                      child: ActionButton(
                        text: 'Confirm Selection & Upload',
                        isLoading: false,
                        onTap: selectedCodes.isEmpty
                            ? () {}
                            : () {
                                Navigator.pop(sheetContext);
                                _dispatchUpload(selectedCodes);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _dispatchUpload(List<String> allowedLanguages) {
    final availableAt = _timingController.availableAt;

    context.read<UploadQuestionsBloc>().add(
      DescUploadParsedQuestions(
        payload: widget.payload,
        courseId: widget.courseId,
        availableAt: availableAt,
        priceSingle: widget.priceSingle,
        priceDual: widget.priceDual,
        testType: widget.testType,
        allowedLanguages: allowedLanguages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<UploadQuestionsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Review Questions',
            style: AppTexts.titleTextStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocConsumer<UploadQuestionsBloc, UploadQuestionsState>(
          listener: (context, state) {
            if (state is UploadFileSuccess) {
              context.go(AppRoutes.adminDashboard);
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
            final isUploading = state is UploadFileInProgress;
            final uploadResult =
                state is UploadFileSuccess ? state.result : null;

            return Column(
              children: [
                NotifyUserTimingWidget(controller: _timingController),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.payload.length,
                    itemBuilder: (context, index) {
                      final question = widget.payload[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            'Question ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Builder(
                            builder: (context) {
                              final data =
                                  (question['languages']
                                      as Map<String, dynamic>)['en'];
                              if (data == null) {
                                return const Text(
                                  'No English content available.',
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabeledText(
                                    'Subject',
                                    question['subject_name'],
                                  ),
                                  _buildLabeledText(
                                    'Topic',
                                    question['topic_name'],
                                  ),
                                  _buildLabeledText(
                                    'Question Type',
                                    question['question_type'],
                                  ),
                                  _buildLabeledText(
                                    'Mark',
                                    question['marks'].toString(),
                                  ),
                                  _buildLabeledText(
                                    'Test Name',
                                    question['test_name'],
                                  ),
                                  10.hGap,
                                  // Question text
                                  MarkdownWidget(
                                    data: data['question_txt'] ?? '',
                                    shrinkWrap: true,
                                  ),
                                  10.hGap,
                                  MarkdownWidget(
                                    data: data['answer_txt'] ?? '',
                                    shrinkWrap: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
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
                            _showLanguageSelectionBottomSheet(context);
                          },
                          text: 'Select Languages & Upload',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabeledText(String label, String? value) {

    return Padding(
      padding: EdgeInsets.all(2.sp),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}
