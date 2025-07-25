import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class UploadQuestions extends StatefulWidget {
  const UploadQuestions({super.key});

  @override
  State<UploadQuestions> createState() => _UploadQuestionsState();
}

class _UploadQuestionsState extends State<UploadQuestions> {
  @override
  void dispose() {
    getIt<UploadQuestionsBloc>().add(ResetUploadState());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload MCQ Questions',
          style: AppTexts.titleTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<UploadQuestionsBloc, UploadQuestionsState>(
        listener: (context, state) {
          if (state is UploadFileSuccess) {
            final r = state.result;
            getIt<SnackBarHelper>().showSuccess(
              'Upload done: ${r.successCount} added, '
              '${r.duplicateCount} duplicates, ${r.failCount} failed.',
            );
          } else if (state is UploadFileFailure) {
            getIt<LogHelper>().e(state.failure.message);
            getIt<SnackBarHelper>().showError(state.failure.message);
          }
        },
        builder: (context, state) {
          if (state is UploadFileInProgress) {
            return Center(child: const CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: ElevatedContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select CSV File', style: AppTexts.heading),
                      Text(
                        'Upload your MCQ questions in CSV format',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      20.hGap,
                      Align(
                        child: BorderedContainer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            // This rounds the inner content
                            child: Column(
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.grey.shade600,
                                  size: 80.sp,
                                ),
                                10.hGap,
                                ActionButton(
                                  text: 'Upload File',
                                  onTap:
                                      () => context
                                          .read<UploadQuestionsBloc>()
                                          .add(UploadCsvAndInsert()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              state is UploadFileSuccess
                  ? Column(
                    children: [
                      10.hGap,
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Upload done: ${state.result.successCount} added, '
                            '${state.result.duplicateCount} duplicates, ${state.result.failCount} failed.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
            ],
          ).padAll(AppPaddings.defaultPadding);
        },
      ),
    );
  }
}
