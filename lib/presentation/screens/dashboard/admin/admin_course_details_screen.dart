import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/share_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/add_course/course_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

class AdminCourseDetailsScreen extends StatefulWidget {
  const AdminCourseDetailsScreen({super.key, required this.courseModel});

  final CourseModel courseModel;

  @override
  State<AdminCourseDetailsScreen> createState() =>
      _AdminCourseDetailsScreenState();
}

class _AdminCourseDetailsScreenState extends State<AdminCourseDetailsScreen> {
  late bool _isActive;
  bool _isLoading = false;
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.courseModel.isActive;
  }

  void _toggleStatus() {
    setState(() {
      _isLoading = true;
    });

    final newValue = !_isActive;

    context.read<CourseBloc>().add(
      ToggleCourseStatusRequested(
        courseId: widget.courseModel.id,
        isActive: newValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prelims = widget.courseModel.tests?.prelims ?? [];
    final descriptive = widget.courseModel.tests?.descriptive ?? [];
    final totalTests = prelims.length + descriptive.length;

    return MultiBlocListener(
      listeners: [
        BlocListener<CourseBloc, CourseState>(
          listener: (context, state) {
            if (state is CourseStatusUpdateSuccess) {
              setState(() {
                _isActive = state.isActive;
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Course ${state.isActive ? "activated" : "deactivated"} successfully',
                  ),
                  backgroundColor: state.isActive
                      ? Colors.green
                      : Colors.orange,
                ),
              );
            } else if (state is CourseStatusUpdateFailure) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update status: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
          listener: (context, state) {
            if (state is DownLoadPdfStarted) {
              setState(() {
                _isDownloadingPdf = true;
              });
            } else if (state is PdfDownloadSuccess) {
              setState(() {
                _isDownloadingPdf = false;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              getIt<SnackBarHelper>().showSuccess("Download successful");
            } else if (state is PdfDownloadFailure) {
              setState(() {
                _isDownloadingPdf = false;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              getIt<SnackBarHelper>().showError(state.failure.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          ),
          title: Text(
            "Course Details (Admin)",
            style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
          ),
          actions: [
            IconButton(
              onPressed: () => ShareHelper.shareCourse(widget.courseModel),
              icon: Icon(
                Icons.share_outlined,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: AppColors.scaffoldColor,
          surfaceTintColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(),
                  16.hGap,
                  
                  // Course Info section
                  _buildCourseHeader(),
                  20.hGap,
                  
                  // Pricing Info Grid
                  _buildMetadataGrid(totalTests),
                  24.hGap,
                  
                  // Action Button
                  _buildActionButton(),
                  28.hGap,
                  
                  // Curriculum/Tests lists
                  _buildCurriculumSection(prelims, descriptive),
                ],
              ),
            ),
            if (_isDownloadingPdf)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: _isActive
            ? const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color:
                (_isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280))
                    .withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isActive ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isActive ? "Course is Active" : "Course is Inactive",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.hGap,
                Text(
                  _isActive
                      ? "Visible to students. They can view details and enroll."
                      : "Hidden from students. They cannot view or purchase.",
                  style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.courseModel.testType?.name.toUpperCase() ?? "COURSE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              12.wGap,
              Text(
                'ID: #${widget.courseModel.id}',
                style: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          14.hGap,
          Text(
            widget.courseModel.name,
            style: AppTexts.titleTextStyle.copyWith(fontSize: 22.sp),
          ),
          12.hGap,
          Text(
            widget.courseModel.description,
            style: AppTexts.subTitle.copyWith(
              color: AppColors.gray700,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataGrid(int totalTests) {
    final singlePrice = widget.courseModel.singleProduct.price;
    final dualPrice = widget.courseModel.dualProduct?.price;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14.w,
      mainAxisSpacing: 14.w,
      childAspectRatio: 1.6,
      children: [
        _buildMetadataCard(
          title: "Single Price",
          value: singlePrice > 0 ? "₹$singlePrice" : "Free",
          icon: Icons.sell_rounded,
          color: Colors.blue,
        ),
        _buildMetadataCard(
          title: "Dual Price",
          value: dualPrice != null && dualPrice > 0 ? "₹$dualPrice" : "N/A",
          icon: Icons.dynamic_feed_rounded,
          color: Colors.purple,
        ),
        _buildMetadataCard(
          title: "Total Tests",
          value: "$totalTests",
          icon: Icons.quiz_rounded,
          color: Colors.orange,
        ),
        _buildMetadataCard(
          title: "Course Type",
          value: widget.courseModel.testType?.name.toUpperCase() ?? "PRELIMS",
          icon: Icons.category_rounded,
          color: Colors.teal,
        ),
        _buildMetadataCard(
          title: "Total Students",
          value: "${widget.courseModel.fullCoursePurchaseCount ?? 0}",
          icon: Icons.people_alt_rounded,
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildMetadataCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18.sp),
              8.wGap,
              Text(
                title,
                style: AppTexts.subTitle.copyWith(
                  color: AppColors.gray500,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          10.hGap,
          Text(
            value,
            style: AppTexts.heading.copyWith(
              fontSize: 16.sp,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _toggleStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isActive
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
          shadowColor:
              (_isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                  .withAlpha(100),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isActive
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20.sp,
                  ),
                  10.wGap,
                  Text(
                    _isActive ? "Deactivate Course" : "Activate Course",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCurriculumSection(
    List<dynamic> prelims,
    List<dynamic> descriptive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Course Curriculum",
          style: AppTexts.heading.copyWith(
            fontSize: 16.sp,
            color: AppColors.gray900,
          ),
        ),
        14.hGap,
        if (prelims.isEmpty && descriptive.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(
              child: Text("No tests added to this course yet."),
            ),
          )
        else ...[
          if (prelims.isNotEmpty) ...[
            _buildSectionHeader("Prelims Tests (${prelims.length})"),
            8.hGap,
            ...prelims.map(
              (test) => _buildTestItem(
                name: test.name,
                info: "${test.duration} Mins • ${test.totalMarks} Marks",
                icon: Icons.quiz_rounded,
                iconColor: Colors.blue,
                onDownload: () =>
                    _showDownloadOptions(test, isDescriptive: false),
              ),
            ),
            16.hGap,
          ],
          if (descriptive.isNotEmpty) ...[
            _buildSectionHeader("Descriptive Tests (${descriptive.length})"),
            8.hGap,
            ...descriptive.map(
              (test) => _buildTestItem(
                name: test.name,
                info: "${test.noQuestions} Questions",
                icon: Icons.description_rounded,
                iconColor: Colors.purple,
                onDownload: () =>
                    _showDownloadOptions(test, isDescriptive: true),
              ),
            ),
          ],
        ],
      ],
    );
  }

  void _showDownloadOptions(dynamic test, {required bool isDescriptive}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  "Download Options",
                  style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text("Question Paper"),
                onTap: () {
                  Navigator.pop(context);
                  _handleDownload(test, isDescriptive, showAnswers: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_outlined),
                title: const Text("Model Answer"),
                onTap: () {
                  Navigator.pop(context);
                  _handleDownload(test, isDescriptive, showAnswers: true);
                },
              ),
              20.hGap,
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDownload(
    dynamic test,
    bool isDescriptive, {
    required bool showAnswers,
  }) async {
    final downloadBloc = context.read<DownLoadPdfBloc>();
    final testRepo = getIt<TestRepository>();

    try {
      if (isDescriptive) {
        final result = await testRepo.fetchDescTestQuestions(test.id);
        result.fold(
          (failure) {
            getIt<LogHelper>().e(failure.message);
            getIt<SnackBarHelper>().showError(failure.message);
          },
          (questions) {
            downloadBloc.add(
              DownloadFullDescTestPdf(
                questions: questions,
                testName: test.name,
                langCodes: test.allowedLanguages ?? ['en'],
                showAnswers: showAnswers,
              ),
            );
          },
        );
      } else {
        if (!showAnswers && test.omrLink != null && test.omrLink.isNotEmpty) {
          downloadBloc.add(
            DownloadPrelimsOmr(
              url: test.omrLink,
              filename: "${test.name.replaceAll(' ', '_')}_QuestionPaper.pdf",
            ),
          );
        } else {
          final result = await testRepo.fetchMcqTestQuestions(test.id);
          result.fold(
            (failure) {
              getIt<LogHelper>().e(failure.message);
              getIt<SnackBarHelper>().showError(failure.message);
            },
            (questions) {
              downloadBloc.add(
                ExportQuestionsToPdfEvent(
                  questions,
                  test.name,
                  testType: TestType.prelims,
                  showAnswers: showAnswers,
                  language: 'en',
                  languages: test.allowedLanguages ?? ['en'],
                ),
              );
            },
          );
        }
      }
    } catch (e) {
      getIt<LogHelper>().e("An error occurred: $e");
      getIt<SnackBarHelper>().showError("An error occurred: $e");
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        title,
        style: AppTexts.title.copyWith(
          color: AppColors.gray700,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildTestItem({
    required String name,
    required String info,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onDownload,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTexts.title.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.gray900,
                  ),
                ),
                4.hGap,
                Text(
                  info,
                  style: AppTexts.subTitle.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          if (onDownload != null)
            IconButton(
              onPressed: onDownload,
              icon: Icon(
                Icons.download_for_offline_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
        ],
      ),
    );
  }
}
