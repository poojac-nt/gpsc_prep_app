import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_peer_review_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/detailed_peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/common/pdf_viewer_screen.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class PeerReviewAnswerScreen extends StatefulWidget {
  final DescQuestionModel question;
  final int index;
  final String userName;
  final int answerId;

  const PeerReviewAnswerScreen({
    super.key,
    required this.question,
    required this.index,
    required this.userName,
    required this.answerId,
  });

  @override
  State<PeerReviewAnswerScreen> createState() => _PeerReviewAnswerScreenState();
}

class _PeerReviewAnswerScreenState extends State<PeerReviewAnswerScreen> {
  late final TextEditingController _feedbackController;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _feedbackController.addListener(_updateWordCount);
    context.read<DetailedPeerReviewBloc>().add(
      FetchDetailedPeerReview(answerId: widget.answerId),
    );
  }

  @override
  void dispose() {
    _feedbackController.removeListener(_updateWordCount);
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
      });
      return;
    }

    final words = text.split(RegExp(r'\s+'));
    setState(() {
      _wordCount = words.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Reviewing Answer',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'by ${widget.userName}',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<DetailedPeerReviewBloc, DetailedPeerReviewState>(
        builder: (context, state) {
          if (state is DetailedPeerReviewLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DetailedPeerReviewError) {
            return Center(child: Text(state.message));
          } else if (state is DetailedPeerReviewLoaded) {
            return _buildContent(state.detail);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(DetailedPeerReviewModel detail) {
    // Resolve dynamic jsonb answer: could be a plain String or a ["url"] List
    String answer = '';
    final raw = detail.answer;
    if (raw is List && raw.isNotEmpty) {
      answer = raw.first.toString();
    } else if (raw is String) {
      answer = raw;
    }

    String answerType = 'text';
    if (answer.startsWith('http')) {
      final lower = answer.toLowerCase();
      if (lower.contains('.pdf')) {
        answerType = 'pdf';
      } else if (lower.contains('.jpg') ||
          lower.contains('.jpeg') ||
          lower.contains('.png') ||
          lower.contains('.webp')) {
        answerType = 'image';
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppPaddings.appPaddingInt),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubmittedAnswerSection(answer, answerType),
                _buildCommentsSection(detail.comments),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppPaddings.appPaddingInt,
            0,
            AppPaddings.appPaddingInt,
            AppPaddings.appPaddingInt,
          ),
          child: _buildFeedbackInput(),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }

  void _handlePdfTap(BuildContext context, String pdfUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                PdfViewerScreen(pdfUrl: pdfUrl, title: 'Submitted Answer'),
      ),
    );
  }

  Widget _buildSubmittedAnswerSection(String answer, String answerType) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'SUBMITTED ANSWER',
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildAnswerContent(answer, answerType),
        ],
      ),
    );
  }

  Widget _buildAnswerContent(String answer, String answerType) {
    switch (answerType) {
      case 'pdf':
        return _buildPdfAnswerCard(answer);
      case 'image':
        return _buildImageAnswerCard(answer);
      case 'text':
      default:
        return _buildTextAnswerCard(answer);
    }
  }

  Widget _buildPdfAnswerCard(String pdfUrl) {
    return Center(
      child: GestureDetector(
        onTap: () => _handlePdfTap(context, pdfUrl),
        child: Container(
          width: 335.w,
          height: 120.h,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 32.sp),
              SizedBox(width: 12.w),
              Text(
                'View Answer (PDF)',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageAnswerCard(String imageUrl) {
    return Center(
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, imageUrl),
        child: Container(
          width: 335.w,
          height: 400.h,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  bottom: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '1/${widget.question.pages ?? 1} Pages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextAnswerCard(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
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
                Icon(
                  Icons.article_outlined,
                  size: 18.sp,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Full Answer Text',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Divider(height: 24.h, color: const Color(0xFFE2E8F0)),
            SelectableText(
              text.trim(),
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(List<Comment> comments) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PEER REVIEWS (${comments.length})',
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 16.h),
          if (comments.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  'No reviews yet. Be the first to review!',
                  style: TextStyle(color: Colors.black45, fontSize: 13.sp),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => SizedBox(height: 20.h),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentTile(comment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    // Generate initials from reviewer name
    final parts = comment.reviewerName.trim().split(RegExp(r'\s+'));
    final initials =
        parts.length >= 2
            ? (parts[0][0] + parts[1][0]).toUpperCase()
            : parts[0][0].toUpperCase();

    final colors = [
      const Color(0xFF1E293B),
      const Color(0xFF8B5CF6),
      const Color(0xFF0F172A),
      const Color(0xFFF43F5E),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
    ];
    final avatarColor =
        colors[comment.reviewerName.hashCode.abs() % colors.length];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: avatarColor,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.reviewerName,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    comment.timeSinceCommentText,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                comment.comment,
                style: TextStyle(
                  color: const Color(0xFF475569),
                  fontSize: 13.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _feedbackController,
                        minLines: 1,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a critique or feedback...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    ActionButton(
                      onTap: () {
                        // TODO: Hook up comment submission
                      },
                      width: 40.w,
                      height: 40.h,
                      padding: EdgeInsets.zero,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      icon: Icons.send,
                      fontColor: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Be respectful and constructive',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$_wordCount/100 words',
                    style: TextStyle(
                      color: _wordCount > 100 ? Colors.red : Colors.black26,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
