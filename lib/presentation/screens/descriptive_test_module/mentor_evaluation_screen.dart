import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/submission_report_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/test_students_list/test_students_list_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/test_students_list/test_students_list_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_evaluation/mentor_evaluation_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_evaluation/mentor_evaluation_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_evaluation/mentor_evaluation_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/document_action_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/score_input_tile.dart';
import 'package:gpsc_prep_app/presentation/widgets/section_header.dart';
import 'package:gpsc_prep_app/presentation/widgets/status_badge.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorEvaluationScreen extends StatefulWidget {
  final MentorEvaluationScreenArgs args;

  const MentorEvaluationScreen({super.key, required this.args});

  @override
  State<MentorEvaluationScreen> createState() => _MentorEvaluationScreenState();
}

class _MentorEvaluationScreenState extends State<MentorEvaluationScreen> {
  final TextEditingController _feedbackController = TextEditingController(
    text: '''
Comment:

Presentation:

Substantiation:

Language and Handwriting:

Suggestion of Improvement:

Positives:
''',
  );
  List<TextEditingController> _scoreControllers = [];
  SubmissionReportModel? _data;
  File? _evaluatedPdfFile;
  List<bool> _scoreErrors = [];

  @override
  void initState() {
    super.initState();
    if (widget.args.submissionId != null) {
      context.read<MentorEvaluationBloc>().add(
        FetchMentorEvaluationData(widget.args.submissionId!),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _scoreControllers) {
      controller.dispose();
    }
    _feedbackController.dispose();
    super.dispose();
  }

  void _initializeControllers(List<Question> questions) {
    if (_scoreControllers.length != questions.length) {
      for (final controller in _scoreControllers) {
        controller.dispose();
      }
      _scoreControllers = List.generate(
        questions.length,
        (index) => TextEditingController(text: ''),
      );
      _scoreErrors = List.generate(questions.length, (index) => false);
    }
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
      body: BlocConsumer<MentorEvaluationBloc, MentorEvaluationState>(
        listener: (context, state) {
          if (state is MentorEvaluationSubmitSuccess) {
            getIt<SnackBarHelper>().showSuccess(
              'Evaluation submitted successfully',
            );
            context.read<TestStudentsListBloc>().add(
              FetchTestStudentsList(widget.args.testId!),
            );
            context.pop();
          } else if (state is MentorEvaluationSubmitError) {
            getIt<SnackBarHelper>().showError(state.message);
          }
        },
        builder: (context, state) {
          if (state is MentorEvaluationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MentorEvaluationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  16.hGap,
                  ElevatedButton(
                    onPressed: () {
                      if (widget.args.submissionId != null) {
                        context.read<MentorEvaluationBloc>().add(
                          FetchMentorEvaluationData(widget.args.submissionId!),
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MentorEvaluationLoaded) {
            _data = state.data;
            _initializeControllers(_data!.questions);
            return _buildContent();
          }

          return const SizedBox.shrink();
        },
      ).padAll(AppPaddings.appPaddingInt),
    );
  }

  Widget _buildContent() {
    if (_data == null) return const SizedBox.shrink();

    return SingleChildScrollView(
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
          BlocBuilder<MentorEvaluationBloc, MentorEvaluationState>(
            builder: (context, state) {
              return ActionButton(
                text:
                    state is MentorEvaluationSubmitting
                        ? 'Submitting...'
                        : 'Submit Evaluation',
                onTap:
                    state is MentorEvaluationSubmitting
                        ? null
                        : _onSubmitEvaluation,
              );
            },
          ),
          24.hGap,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Student Info Header
  // ─────────────────────────────────────────────
  Widget _buildStudentInfoHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                widget.args.studentName ?? 'Student',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              4.hGap,
              Text(
                widget.args.testName ?? 'Test',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              8.hGap,
              widget.args.isChecked == true
                  ? StatusBadge.evaluated()
                  : StatusBadge.inProgress(),
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
          subtitle: 'Student Answer Script',
          onTap: () {
            if (_data?.submissionPdfUrl != null) {
              context.read<DownLoadPdfBloc>().add(
                DownloadStudyMaterial(
                  url: _data!.submissionPdfUrl!,
                  filename:
                      '${widget.args.studentName ?? 'student'}_${widget.args.testName ?? 'test'}.pdf',
                ),
              );
            } else {
              getIt<SnackBarHelper>().showError('Student PDF URL not found');
            }
          },
        ),
        12.hGap,
        DocumentActionCard(
          icon: Icons.upload_file_rounded,
          title: 'Upload Evaluated PDF',
          subtitle:
              _evaluatedPdfFile != null
                  ? _evaluatedPdfFile!.path.split('/').last
                  : 'Drop file or click to browse',
          iconColor: const Color(0xFF059669),
          iconBackgroundColor: const Color(0xFFD1FAE5),
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );

            if (result != null && result.files.single.path != null) {
              setState(() {
                _evaluatedPdfFile = File(result.files.single.path!);
              });
            }
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Scoring Section
  // ─────────────────────────────────────────────
  Widget _buildScoringSection() {
    final questions = _data?.questions ?? [];
    return Column(
      children: List.generate(questions.length, (index) {
        final question = questions[index];
        return ScoreInputTile(
          questionLabel: 'Question ${index + 1}',
          maxMarks: question.maxMarks,
          controller: _scoreControllers[index],
          isError: _scoreErrors[index],
          errorMessage: 'Marks cannot exceed ${question.maxMarks}',
          onChanged: (value) {
            final marks = int.tryParse(value) ?? 0;
            if (marks > question.maxMarks) {
              setState(() {
                _scoreErrors[index] = true;
              });
            } else if (_scoreErrors[index]) {
              setState(() {
                _scoreErrors[index] = false;
              });
            }
          },
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
        minLines: 8,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.6),
        cursorColor: AppColors.primary,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Submit Handler
  // ─────────────────────────────────────────────
  void _onSubmitEvaluation() {
    if (_data == null || widget.args.submissionId == null) return;

    final Map<String, dynamic> scores = {};

    bool hasError = false;
    for (int i = 0; i < _data!.questions.length; i++) {
      final question = _data!.questions[i];
      final marksStr = _scoreControllers[i].text.trim();
      final marks = int.tryParse(marksStr) ?? 0;

      if (marks > question.maxMarks) {
        setState(() {
          _scoreErrors[i] = true;
        });
        hasError = true;
      } else {
        setState(() {
          _scoreErrors[i] = false;
        });
      }
      scores[question.questionId.toString()] = marks;
    }

    if (hasError) {
      getIt<SnackBarHelper>().showError(
        'Please correct the marks exceeding maximum limit',
      );
      return;
    }

    context.read<MentorEvaluationBloc>().add(
      SubmitMentorEvaluation(
        submissionId: widget.args.submissionId!,
        mentorAssignmentId: widget.args.mentorAssignmentId,
        questionScores: scores,
        feedback: _feedbackController.text,
        evaluatedPdfFile: _evaluatedPdfFile,
      ),
    );
  }
}
