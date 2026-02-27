import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/peer_submission_tile.dart';
import 'package:gpsc_prep_app/presentation/widgets/question_detail_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class DescriptiveAnswerDetailScreen extends StatefulWidget {
  final DescQuestionModel question;
  final int index;

  const DescriptiveAnswerDetailScreen({
    super.key,
    required this.question,
    required this.index,
  });

  @override
  State<DescriptiveAnswerDetailScreen> createState() =>
      _DescriptiveAnswerDetailScreenState();
}

class _DescriptiveAnswerDetailScreenState
    extends State<DescriptiveAnswerDetailScreen> {
  String _currentLanguage = 'en';

  List<String> get _availableLanguages {
    final langs = <String>['en'];
    if (widget.question.questionHi != null) langs.add('hi');
    if (widget.question.questionGj != null) langs.add('gj');
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
    final availableLangsCount = _availableLanguages.length;

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
          'Question Q.${widget.index + 1}',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            QuestionDetailCard(
              question: widget.question,
              index: widget.index,
              timeLeft: '2 days left',
              commentCount: 16,
              selectedLanguage: _currentLanguage,
            ),
            _buildPeerSubmissionsHeader(),
            _buildPeerSubmissionsList(),
            SizedBox(height: 30.h),
          ],
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 4,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final dummyUsers = [
          'Amit Mishra',
          'Nimitha Paliyal',
          'Dhirendra',
          'Khushi Kour',
        ];
        final dummyStates = ['Top Contributor', 'New User', 'Member', 'Expert'];
        final dummyInitials = ['AM', 'NP', 'DH', 'KK'];
        final dummyColors = [
          const Color(0xFF1E293B),
          const Color(0xFF8B5CF6),
          const Color(0xFF0F172A),
          const Color(0xFFF43F5E),
        ];

        return PeerSubmissionTile(
          userName: dummyUsers[index % 4],
          userInitial: dummyInitials[index % 4],
          userStatus: index % 2 == 0 ? dummyStates[index % 4] : null,
          timeAgo: '${index + 1}y ago',
          reviewCount: index + 1,
          previewText:
              index == 0
                  ? 'The decline of British power was multifaceted. My answer focuses on the impact of World War II...'
                  : 'I tried to link the INA trials with the mutiny directly. Is my conclusion strong enough?',
          isFeatured: index == 0,
          previewImageUrl:
              index % 3 == 0
                  ? 'https://via.placeholder.com/150x80/E2E8F0/64748B?text=Answer+Sheet'
                  : null,
          baseColor: dummyColors[index % 4],
          onReviewPressed: () {
            context.push(
              AppRoutes.peerReviewAnswer,
              extra: {
                'question': widget.question,
                'index': widget.index,
                'userName': dummyUsers[index % 4],
              },
            );
          },
        );
      },
    );
  }
}
