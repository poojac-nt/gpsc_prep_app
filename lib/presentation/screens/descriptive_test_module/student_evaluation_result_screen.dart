import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/mains_test_review_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test_result/mains_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';

import '../../../core/router/args.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/extensions/padding.dart';
import '../../widgets/action_button.dart';
import '../../widgets/section_header.dart';

class StudentEvaluationResultScreen extends StatefulWidget {
  final StudentEvaluationResultScreenArgs args;

  const StudentEvaluationResultScreen({super.key, required this.args});

  @override
  State<StudentEvaluationResultScreen> createState() =>
      _StudentEvaluationResultScreenState();
}

class _StudentEvaluationResultScreenState
    extends State<StudentEvaluationResultScreen> {
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    context.read<MainsTestReviewBloc>().add(
      FetchMainsTestReview(widget.args.testId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
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
      child: Scaffold(
        backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Evaluation Result', style: AppTexts.titleTextStyle),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          BlocBuilder<MainsTestReviewBloc, MainsTestReviewState>(
        builder: (context, state) {
          if (state is MainsTestReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MainsTestReviewError) {
            return Center(child: Text(state.message));
          } else if (state is MainsTestReviewLoaded) {
            final result = state.result;

            // Find the selected mentor's review or default to the first one
            final selectedReview = result.mentorReviews.firstWhere(
              (m) => m.mentorId == widget.args.mentorId,
              orElse: () => result.mentorReviews.first,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Student Info Card ──
                  _buildStudentInfoCard(result, selectedReview),
                  16.hGap,

                  // ── Download Evaluated PDF Section ──
                  if (selectedReview.reviewedPdfUrl != null)
                    _buildDownloadPdfSection(result, selectedReview),
                  16.hGap,

                  // ── Total Score Section ──
                  _buildTotalScoreSection(
                    selectedReview,
                    result.testTotalMarks,
                  ),
                  16.hGap,

                  // ── Question-wise Breakdown ──
                  const SectionHeader(
                    title: 'Question-wise Breakdown',
                    padding: EdgeInsets.zero,
                  ),
                  12.hGap,
                  _buildQuestionBreakdown(selectedReview),
                  16.hGap,

                  // ── Selected Mentor Feedback ──
                  _buildOverallFeedback(selectedReview),
                  24.hGap,
                ],
              ).padAll(16.w),
            );
          }
          return const SizedBox.shrink();
        },
      ),
          if (_isDownloadingPdf)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildStudentInfoCard(
    MainsTestReviewModel result,
    MentorReviewDetail selectedReview,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: const Color(0xFFC08E55),
            child: Icon(Icons.person, size: 35.sp, color: Colors.white),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.studentName ?? 'Student',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                4.hGap,
                Text(
                  result.testName,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                4.hGap,
                Text(
                  "Evaluated by: ${selectedReview.mentorName}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPdfSection(
    MainsTestReviewModel result,
    MentorReviewDetail selectedReview,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD1E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download Evaluated PDF',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          8.hGap,
          Text(
            "View mentor's inline comments and annotations on your answer sheet.",
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
          20.hGap,
          BlocBuilder<DownLoadPdfBloc, DownLoadPdfState>(
            builder: (context, downloadState) {
              final isDownloading = downloadState is DownLoadPdfStarted;
              return ActionButton(
                text: 'Download Evaluated PDF',
                icon: Icons.download_rounded,
                isLoading: isDownloading,
                onTap: () {
                  String fileName =
                      "${widget.args.testName ?? 'Test'}_Reviewed";

                  if (result.mentorReviews.length > 1) {
                    int reviewIndex =
                        result.mentorReviews.indexWhere(
                          (m) => m.mentorId == selectedReview.mentorId,
                        ) +
                        1;
                    fileName +=
                        "_by_${selectedReview.mentorName}_Review_$reviewIndex";
                  }

                  fileName += ".pdf";
                  fileName = fileName.replaceAll(' ', '_');

                  context.read<DownLoadPdfBloc>().add(
                    DownloadStudyMaterial(
                      url: selectedReview.reviewedPdfUrl!,
                      filename: fileName,
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
              );
            },
          ),
          16.hGap,
          ActionButton(
            text: 'Download Model Answers',
            icon: Icons.download_rounded,
            onTap: () async {
              setState(() {
                _isDownloadingPdf = true;
              });
              final downloadBloc = context.read<DownLoadPdfBloc>();
              final testRepo = getIt<TestRepository>();
              final result = await testRepo.fetchDescTestQuestions(
                widget.args.descTestModel.id,
              );
              result.fold(
                (failure) {
                  setState(() {
                    _isDownloadingPdf = false;
                  });
                  getIt<LogHelper>().e(failure.message);
                  getIt<SnackBarHelper>().showError(failure.message);
                },
                (questions) {
                  downloadBloc.add(
                    DownloadFullDescTestPdf(
                      questions: questions,
                      testName: widget.args.descTestModel.name,
                      langCodes:
                          widget.args.descTestModel.allowedLanguages ?? ['en'],
                      showAnswers: true,
                    ),
                  );
                },
              );
            },
            backgroundColor: AppColors.primary,
          ),
          16.hGap,
          ActionButton(
            text: 'View Model Answers',
            icon: Icons.lightbulb_outline_rounded,
            onTap: () {
              context.push(
                AppRoutes.descFullQuestions,
                extra: DescFullQuestionsScreenArgs(
                  testId: widget.args.testId ?? 0,
                  testName: widget.args.testName ?? 'Test',
                  courseId: widget.args.courseId,
                  isSubmitted: true,
                  descTestModel: widget.args.descTestModel,
                ),
              );
            },
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreSection(MentorReviewDetail review, int maxMarks) {
    final totalScore = review.totalMarks ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL SCORE',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          12.hGap,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$totalScore ',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: '/ $maxMarks',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          16.hGap,
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: maxMarks == 0 ? 0 : totalScore / maxMarks,
              minHeight: 8.h,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBreakdown(MentorReviewDetail review) {
    final scores = [...review.questionScores]
      ..sort((a, b) => (a.questionOrder ?? 0).compareTo(b.questionOrder ?? 0));

    if (scores.isEmpty) {
      return const Text("Not reviewed yet");
    }

    return Column(
      children: scores.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;

        final gained = question.gainedMarks ?? 0;
        final total = question.totalMarks;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$gained ',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: '/ $total',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverallFeedback(MentorReviewDetail mentorReview) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
              10.wGap,
              Text(
                'Mentor Feedback',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          16.hGap,
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                16.wGap,
                Expanded(
                  child: Text(
                    mentorReview.feedback ?? "No overall feedback provided.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          24.hGap,
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
              12.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mentorReview.mentorName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'MENTOR',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
