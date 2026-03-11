import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/section_header.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class StudentEvaluationResultScreen extends StatelessWidget {
  final StudentEvaluationResultScreenArgs args;

  const StudentEvaluationResultScreen({super.key, required this.args});

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Student Info Card ──
            _buildStudentInfoCard(),
            16.hGap,

            // ── Download Evaluated PDF Section ──
            _buildDownloadPdfSection(),
            16.hGap,

            // ── Total Score Section ──
            _buildTotalScoreSection(),
            16.hGap,

            // ── Question-wise Breakdown ──
            const SectionHeader(
              title: 'Question-wise Breakdown',
              padding: EdgeInsets.zero,
            ),
            12.hGap,
            _buildQuestionBreakdown(),
            16.hGap,

            // ── Overall Feedback ──
            _buildOverallFeedback(),
            24.hGap,
          ],
        ).padAll(16.w),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
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
                  args.studentName ?? 'Arjun Mehta',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                4.hGap,
                Text(
                  args.testName ?? 'Prelims Full Test - 05',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadPdfSection() {
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
            onTap: () {},
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreSection() {
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
                  text: '74 ',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: '/ 150',
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
              value: 74 / 150,
              minHeight: 8.h,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBreakdown() {
    final List<Map<String, dynamic>> questions = [
      {'label': 'Question 01', 'score': 8, 'max': 10},
      {'label': 'Question 02', 'score': 6.5, 'max': 10},
      {'label': 'Question 03', 'score': 4, 'max': 10},
      {'label': 'Question 04', 'score': 9, 'max': 10},
    ];

    return Column(
      children:
          questions.map((q) {
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
                    q['label'],
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
                          text: '${q['score']} ',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: '/ ${q['max']}',
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

  Widget _buildOverallFeedback() {
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
                'Overall Feedback',
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
                    '"Arjun, your conceptual clarity in the static portions of Geography and History is impressive. However, you need to focus more on current affairs integration in your answers. Work on your time management as Question 03 seemed rushed. Overall, a solid performance, but there is significant room for improvement in data representation through diagrams."',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Rajesh Kumar',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'SENIOR MENTOR',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
