import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/blocs/peer_review/peer_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/peer_submission_tile.dart';
import 'package:gpsc_prep_app/presentation/widgets/question_detail_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import 'package:gpsc_prep_app/presentation/blocs/peer_review/submit_peer_review_bloc.dart';

class DescriptiveAnswerDetailScreen extends StatefulWidget {
  final DescriptiveAnswerDetailScreenArgs args;

  const DescriptiveAnswerDetailScreen({super.key, required this.args});

  @override
  State<DescriptiveAnswerDetailScreen> createState() =>
      _DescriptiveAnswerDetailScreenState();
}

class _DescriptiveAnswerDetailScreenState
    extends State<DescriptiveAnswerDetailScreen> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    if (widget.args.showPeerReview) {
      context.read<PeerReviewBloc>().add(
        FetchPeerReviews(
          testId: widget.args.testId,
          questionId: widget.args.question.id,
        ),
      );
    }
  }

  List<String> get _availableLanguages {
    final langs = <String>['en'];
    if (widget.args.question.questionHi != null) langs.add('hi');
    if (widget.args.question.questionGj != null) langs.add('gj');
    return langs;
  }

  String _getLanguageChar(String lang) {
    switch (lang) {
      case 'en':
        return 'A';
      case 'hi':
        return 'अ';
      case 'gj':
        return 'અ';
      default:
        return 'A';
    }
  }

  void _switchToNextLanguage() {
    final langs = _availableLanguages;
    if (langs.length <= 1) return;

    final currentIndex = langs.indexOf(_currentLanguage);
    final nextIndex = (currentIndex + 1) % langs.length;
    setState(() {
      _currentLanguage = langs[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.args.showPeerReview
              ? 'Question ${widget.args.index + 1}'
              : 'Model Answer ${widget.args.index + 1}',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _switchToNextLanguage,
            child: Text(
              _getLanguageChar(_currentLanguage),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: BlocListener<SubmitPeerReviewBloc, SubmitPeerReviewState>(
        listener: (context, state) {
          if (state is SubmitPeerReviewSuccess) {
            context.read<PeerReviewBloc>().add(
              FetchPeerReviews(
                testId: widget.args.testId,
                questionId: widget.args.question.id,
              ),
            );
            // Reset state to avoid repeated refreshing if this screen rebuilds
            context.read<SubmitPeerReviewBloc>().add(
              ResetSubmitPeerReviewState(),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              QuestionDetailCard(
                question: widget.args.question,
                index: widget.args.index,
                commentCount: 16,
                selectedLanguage: _currentLanguage,
                isUnlocked: widget.args.isUnlocked,
              ),
              if (widget.args.showPeerReview) ...[
                _buildPeerSubmissionsHeader(),
                _buildPeerSubmissionsList(),
              ],
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeerSubmissionsHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Peer Submissions',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerSubmissionsList() {
    return BlocBuilder<PeerReviewBloc, PeerReviewState>(
      builder: (context, state) {
        if (state is PeerReviewLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is PeerReviewError) {
          return Center(child: Text(state.message));
        } else if (state is PeerReviewLoaded) {
          final peerReviews = state.peerReviews;
          if (peerReviews.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No peer submissions yet.'),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: peerReviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final review = peerReviews[index];

              // Resolve dynamic jsonb answer
              String answerType = 'text';
              String? answerText;
              String? previewImageUrl;

              final raw = review.answer;
              String resolvedAnswer = '';
              if (raw is List && raw.isNotEmpty) {
                resolvedAnswer = raw.first.toString();
              } else if (raw is String) {
                resolvedAnswer = raw;
              }

              if (resolvedAnswer.startsWith('http')) {
                final lower = resolvedAnswer.toLowerCase();
                if (lower.contains('.pdf')) {
                  answerType = 'pdf';
                } else if (lower.contains('.jpg') ||
                    lower.contains('.jpeg') ||
                    lower.contains('.png') ||
                    lower.contains('.webp')) {
                  answerType = 'image';
                  previewImageUrl = resolvedAnswer;
                }
              } else if (resolvedAnswer.isNotEmpty) {
                answerText = resolvedAnswer;
              }
              final isMe = review.userId == getIt<CacheManager>().getUserId();
              return PeerSubmissionTile(
                userName: review.fullName,
                isMe: isMe,
                answerSubmittedAgo: review.timeSinceLatestComment,
                latestComment: review.latestComment,
                answerType: answerType,
                answerText: answerText,
                previewImageUrl: previewImageUrl,
                onReviewPressed: () {
                  context.push(
                    AppRoutes.peerReviewAnswer,
                    extra: PeerReviewAnswerScreenArgs(
                      question: widget.args.question,
                      index: widget.args.index,
                      userName: review.fullName,
                      answerId: review.answerId,
                    ),
                  );
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
