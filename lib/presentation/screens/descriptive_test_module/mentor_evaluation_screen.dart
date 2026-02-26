import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/document_action_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/score_input_tile.dart';
import 'package:gpsc_prep_app/presentation/widgets/section_header.dart';
import 'package:gpsc_prep_app/presentation/widgets/status_badge.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

/// Mock data model for questions shown in the scoring section.
class _MockQuestion {
  final String label;
  final String subject;
  final int maxMarks;

  const _MockQuestion({
    required this.label,
    required this.subject,
    required this.maxMarks,
  });
}

class MentorEvaluationScreen extends StatefulWidget {
  const MentorEvaluationScreen({super.key});

  @override
  State<MentorEvaluationScreen> createState() => _MentorEvaluationScreenState();
}

class _MentorEvaluationScreenState extends State<MentorEvaluationScreen> {
  // Mock data — will be replaced with real data from backend
  final String _studentName = 'Arjun Mehta';
  final String _testName = 'Test: Prelims Full Test - 05';
  final String _studentPdfFile = 'prelims_05_arjun.pdf';

  final List<_MockQuestion> _questions = const [
    _MockQuestion(
      label: 'Question 01',
      subject: 'History & Culture',
      maxMarks: 10,
    ),
    _MockQuestion(label: 'Question 02', subject: 'Geography', maxMarks: 10),
    _MockQuestion(
      label: 'Question 03',
      subject: 'Polity & Governance',
      maxMarks: 15,
    ),
  ];

  late final List<TextEditingController> _scoreControllers;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scoreControllers = List.generate(
      _questions.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers) {
      controller.dispose();
    }
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Evaluation Workspace', style: AppTexts.titleTextStyle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Student Info Header ──
            _buildStudentInfoHeader(),
            16.hGap,

            // ── Document Actions ──
            const SectionHeader(title: 'Document Actions'),
            _buildDocumentActions(),

            // ── Scoring & Feedback ──
            const SectionHeader(title: 'Scoring & Feedback'),
            _buildScoringSection(),

            // ── Overall Feedback ──
            const SectionHeader(title: 'Overall Feedback'),
            _buildFeedbackField(),
            24.hGap,

            // ── Submit Button ──
            ActionButton(text: 'Submit Evaluation', onTap: _onSubmitEvaluation),
            24.hGap,
          ],
        ),
      ).padAll(AppPaddings.appPaddingInt),
    );
  }

  // ─────────────────────────────────────────────
  //  Student Info Header
  // ─────────────────────────────────────────────
  Widget _buildStudentInfoHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Icon(Icons.person, size: 30.sp, color: AppColors.primary),
        ),
        12.wGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _studentName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              4.hGap,
              Text(
                _testName,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              8.hGap,
              StatusBadge.inProgress(),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Document Actions
  // ─────────────────────────────────────────────
  Widget _buildDocumentActions() {
    return Column(
      children: [
        DocumentActionCard(
          icon: Icons.download_rounded,
          title: 'Download Student PDF',
          subtitle: 'File: $_studentPdfFile',
          onTap: () {
            // TODO: Implement PDF download
          },
        ),
        12.hGap,
        DocumentActionCard(
          icon: Icons.upload_file_rounded,
          title: 'Upload Evaluated PDF',
          subtitle: 'Drop file or click to browse',
          iconColor: const Color(0xFF059669),
          iconBackgroundColor: const Color(0xFFD1FAE5),
          onTap: () {
            // TODO: Implement PDF upload
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Scoring Section
  // ─────────────────────────────────────────────
  Widget _buildScoringSection() {
    return Column(
      children: List.generate(_questions.length, (index) {
        final question = _questions[index];
        return ScoreInputTile(
          questionLabel: question.label,
          subject: question.subject,
          maxMarks: question.maxMarks,
          controller: _scoreControllers[index],
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  //  Overall Feedback
  // ─────────────────────────────────────────────
  Widget _buildFeedbackField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextField(
        controller: _feedbackController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Enter detailed qualitative feedback for the student...',
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
        cursorColor: AppColors.primary,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Submit Handler (placeholder)
  // ─────────────────────────────────────────────
  void _onSubmitEvaluation() {
    // TODO: Implement evaluation submission
    debugPrint('Scores: ${_scoreControllers.map((c) => c.text).toList()}');
    debugPrint('Feedback: ${_feedbackController.text}');
  }
}
