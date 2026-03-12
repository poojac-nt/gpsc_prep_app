import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/mains_test_review_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test_result/mains_test_review_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  void initState() {
    context.read<MainsTestReviewBloc>().add(
      FetchMainsTestReview(widget.args.testId!),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Evaluation Result', style: AppTexts.titleTextStyle),
        centerTitle: false,
      ),
      body: BlocBuilder<MainsTestReviewBloc, MainsTestReviewState>(
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
                    _buildDownloadPdfSection(selectedReview),
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

  Widget _buildDownloadPdfSection(MentorReviewDetail selectedReview) {
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
          ActionButton(
            text: 'Download Evaluated PDF',
            icon: Icons.download_rounded,
            onTap: () async {
              final url = Uri.parse(selectedReview.reviewedPdfUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreSection(MentorReviewDetail review, int maxMarks) {
    final totalScore = review.totalMarks;

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
                  text: '${totalScore.toStringAsFixed(1)} ',
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
    final scores = review.questionScores;

    if (scores.isEmpty) {
      return const Text("Not reviewed yet");
    }

    return Column(
      children:
          scores.asMap().entries.map((entry) {
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
