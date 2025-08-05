import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ReviewQuestionUploadScreen extends StatelessWidget {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;

  const ReviewQuestionUploadScreen({
    super.key,
    required this.payload,
    required this.isTestUpload,
  });

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
            final isUploading = state is UploadFileInProgress;
            final uploadResult =
                state is UploadFileSuccess ? state.result : null;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: payload.length,
                    itemBuilder: (context, index) {
                      final question = payload[index];
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
                              final correctAnswer =
                                  data['correct_answer']; // e.g., "option_c"

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
                                    'Test Type',
                                    question['test_type'],
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
                                  // Options A-D
                                  for (final entry
                                      in {
                                        'option_a': data['opt_a'],
                                        'option_b': data['opt_b'],
                                        'option_c': data['opt_c'],
                                        'option_d': data['opt_d'],
                                      }.entries)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        entry.value ?? '',
                                        style: TextStyle(
                                          fontWeight:
                                              entry.key == correctAnswer
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              entry.key == correctAnswer
                                                  ? Colors.green
                                                  : null,
                                        ),
                                      ),
                                    ),

                                  // Explanation
                                  if ((data['explanation'] ?? '')
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.h),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Explanation:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          5.hGap,
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
                            context.read<UploadQuestionsBloc>().add(
                              UploadParsedQuestionsToSupabase(
                                payload: payload,
                                isTestUpload: isTestUpload,
                              ),
                            );
                          },
                          text: 'Confirm & Upload',
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
