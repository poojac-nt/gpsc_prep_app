import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/upload%20questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class UploadQuestions extends StatefulWidget {
  const UploadQuestions({super.key});

  @override
  State<UploadQuestions> createState() => _UploadQuestionsState();
}

class _UploadQuestionsState extends State<UploadQuestions> {
  late UploadQuestionsBloc uploadQuestionsBloc;

  @override
  void initState() {
    uploadQuestionsBloc = context.read<UploadQuestionsBloc>();
    uploadQuestionsBloc.add(FetchCoursesRequested());
    super.initState();
  }

  @override
  void dispose() {
    uploadQuestionsBloc.add(ResetUploadState());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Test & Questions',
          style: AppTexts.titleTextStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<UploadQuestionsBloc, UploadQuestionsState>(
        listener: (context, state) {
          if (state is ParseFileFailure) {
            getIt<SnackBarHelper>().showError(state.errorMessage);
          }
          if (state is McqParseFileSuccess) {
            context.push(
              AppRoutes.reviewQuestion,
              extra: ReviewQuestionScreenArgs(
                isTestUpload: state.isTestUpload,
                payload: state.parsedPayload,
                isFromStudyMaterial: false,
                courseId: state.courseId,
              ),
            );
          }
          if (state is DescParseFileSuccess) {
            context.push(
              AppRoutes.descReviewQuestion,
              extra: DescReviewQuestionScreenArgs(
                payload: state.parsedPayload,
                courseId: state.courseId,
              ),
            );
          }
          if (state is CoursesLoaded) {
            setState(() {
              _courses = state.courses;
            });
          }
          if (state is CoursesLoadFailure) {
            getIt<SnackBarHelper>().showError(state.errorMessage);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is ParseFileInProgress || state is CoursesLoading;
          final testType = _selectedCourse?.testType?.toString().toLowerCase();

          final isMains = testType == 'mains';
          final isPrelims = testType == 'prelims';
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppPaddings.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCourseSelection(context),
                30.hGap,
                _buildSectionHeader(
                  title: 'MCQ Upload',
                  subtitle: 'Upload questions for Prelims/MCQ tests',
                  icon: Icons.checklist_rtl_rounded,
                ),
                20.hGap,
                Opacity(
                  opacity: isMains ? 0.5 : 1.0,
                  child: AbsorbPointer(
                    absorbing: isMains,
                    child: _buildMcqUploadSection(context, isLoading),
                  ),
                ),
                40.hGap,
                _buildSectionHeader(
                  title: 'Descriptive Upload',
                  subtitle: 'Upload questions for Descriptive tests',
                  icon: Icons.description_outlined,
                ),
                20.hGap,
                Opacity(
                  opacity: isPrelims ? 0.5 : 1.0,
                  child: AbsorbPointer(
                    absorbing: isPrelims,
                    child: _buildDescUploadSection(context, isLoading),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 10),
                AppColors.primary.withAlpha(05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary.withAlpha(10),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28.sp),
        ),
        16.wGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTexts.dashboardMediumTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.primary,
                ),
              ),
              Text(
                subtitle,
                style: AppTexts.subTitle.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<CourseModel> _courses = [];

  Widget _buildCourseSelection(BuildContext context) {
    return ElevatedContainer(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Course',
                  style: AppTexts.subTitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await context.push<Map<String, dynamic>>(
                      AppRoutes.addCourse,
                    );
                    if (result != null && result['id'] != null) {
                      uploadQuestionsBloc.add(FetchCoursesRequested());
                    }
                  },
                  icon: Icon(Icons.add, size: 20.sp),
                  label: Text('Add Course'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            8.hGap,
            DropdownButtonFormField<int?>(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                hintText: 'Choose a course...',
              ),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text('None')),
                ..._courses.map((e) {
                  return DropdownMenuItem<int?>(
                    value: e.id,
                    child: Text(e.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    _selectedCourse = null;
                  } else {
                    try {
                      _selectedCourse = _courses.firstWhere(
                        (element) => element.id == value,
                      );
                    } catch (e) {
                      _selectedCourse = null;
                    }
                  }
                });
              },
              initialValue: _selectedCourse?.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMcqUploadSection(BuildContext context, bool isLoading) {
    return ElevatedContainer(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Action',
              style: AppTexts.subTitle.copyWith(fontWeight: FontWeight.bold),
            ),
            16.hGap,
            Column(
              children: [
                ActionButton(
                  isLoading: isLoading,
                  text: 'Bulk Questions',
                  icon: Icons.copy_all_rounded,
                  backgroundColor: AppColors.primary,
                  onTap: () {
                    context.read<UploadQuestionsBloc>().add(
                      McqParseUploadFile(isTestUpload: false, courseId: null),
                    );
                  },
                ),
                16.hGap,
                ActionButton(
                  isLoading: isLoading,
                  text: 'Test with Questions',
                  icon: Icons.quiz_outlined,
                  backgroundColor: AppColors.primary,
                  onTap: () {
                    context.read<UploadQuestionsBloc>().add(
                      McqParseUploadFile(
                        isTestUpload: true,
                        courseId: _selectedCourse?.id,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescUploadSection(BuildContext context, bool isLoading) {
    return ElevatedContainer(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30.h),
              decoration: BoxDecoration(
                color: AppColors.scaffoldColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary.withAlpha(50),
                    size: 40.sp,
                  ),
                  10.hGap,
                  Text(
                    'Support CSV or Excel files',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            20.hGap,
            SizedBox(
              width: double.infinity,
              child: ActionButton(
                isLoading: isLoading,
                text: 'Upload Descriptive Test',
                icon: Icons.upload_file,
                backgroundColor: AppColors.primary,
                onTap: () {
                  context.read<UploadQuestionsBloc>().add(
                    DescParseUploadFile(courseId: _selectedCourse?.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  CourseModel? _selectedCourse;
}
