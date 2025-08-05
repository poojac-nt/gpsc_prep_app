import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
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
    context.read<UploadQuestionsBloc>().add(ResetUploadState());
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
          if (state is ParseFileFailure) {
            getIt<SnackBarHelper>().showError(state.errorMessage);
          }

          if (state is ParseFileSuccess) {
            context.push(
              AppRoutes.reviewQuestion,
              extra: ReviewQuestionScreenArgs(
                isTestUpload: state.isTestUpload,
                payload: state.parsedPayload,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ParseFileInProgress;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: ElevatedContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select CSV or XLSX File', style: AppTexts.heading),
                      Text(
                        'Upload your MCQ questions in CSV or Excel format',
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
                            child: Column(
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: Colors.grey.shade600,
                                  size: 80.sp,
                                ),
                                10.hGap,
                                ActionButton(
                                  isLoading: isLoading,
                                  text: 'Bulk Insertion',
                                  onTap: () {
                                    context.read<UploadQuestionsBloc>().add(
                                      ParseUploadFile(isTestUpload: false),
                                    );
                                  },
                                ),
                                10.hGap,
                                ActionButton(
                                  isLoading: isLoading,
                                  text: 'Insert Question with Tests',
                                  onTap: () {
                                    context.read<UploadQuestionsBloc>().add(
                                      ParseUploadFile(isTestUpload: true),
                                    );
                                  },
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
            ],
          ).padAll(AppPaddings.defaultPadding);
        },
      ),
    );
  }
}
