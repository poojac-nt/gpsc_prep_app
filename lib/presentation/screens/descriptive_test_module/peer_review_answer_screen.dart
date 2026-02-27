import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/common/pdf_viewer_screen.dart';
import 'package:gpsc_prep_app/presentation/widgets/question_detail_card.dart';

class PeerReviewAnswerScreen extends StatefulWidget {
  final DescQuestionModel question;
  final int index;
  final String userName;

  const PeerReviewAnswerScreen({
    super.key,
    required this.question,
    required this.index,
    required this.userName,
  });

  @override
  State<PeerReviewAnswerScreen> createState() => _PeerReviewAnswerScreenState();
}

class _PeerReviewAnswerScreenState extends State<PeerReviewAnswerScreen> {
  late final TextEditingController _feedbackController;
  int _wordCount = 0;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _feedbackController.addListener(_updateWordCount);
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionDetailCard(
                    question: widget.question,
                    index: widget.index,
                    selectedLanguage: _currentLanguage,
                  ),
                  _buildSubmittedAnswerSection(),
                  _buildCommentsSection(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          _buildFeedbackInput(),
        ],
      ),
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

  // ── Dummy answer data ──
  // answerType can be: 'text', 'image', 'pdf'
  static const String _dummyAnswerType =
      'pdf'; // Change to test different types

  static const String _dummyPdfUrl =
      'https://fwsghwropuovskeqyawb.supabase.co/storage/v1/object/public/answers/answers/98_1287_42_1764567419022_28%20Nov%202025.pdf';

  static const String _dummyImageUrl =
      'https://fwsghwropuovskeqyawb.supabase.co/storage/v1/object/public/answers/answers/70_753_164_1761490399381_IMG_20251026_202214.jpg';

  static const String _dummyTextAnswer = '''
## Gujarat's Administrative Structure

Gujarat follows a **three-tier administrative structure**:

1. **State Level** – Headed by the Governor and the Chief Minister with the Council of Ministers.
2. **District Level** – Each of the 33 districts is headed by a District Collector (IAS officer).
3. **Local Level** – Comprises Municipal Corporations, Municipalities, and Panchayati Raj institutions.

### Key Points:
- The **Gujarat Panchayats Act, 1993** governs the local self-government bodies.
- Urban governance is managed through **8 Municipal Corporations** and **162 Municipalities**.
- The state has a **unicameral legislature** with 182 seats in the Vidhan Sabha.

> The decentralization of power ensures participatory governance at the grassroots level, which is essential for effective public administration.
''';

  Widget _buildSubmittedAnswerSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
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
          _buildAnswerContent(),
        ],
      ),
    );
  }

  Widget _buildAnswerContent() {
    switch (_dummyAnswerType) {
      case 'pdf':
        return _buildPdfAnswerCard();
      case 'image':
        return _buildImageAnswerCard();
      case 'text':
      default:
        return _buildTextAnswerCard();
    }
  }

  Widget _buildPdfAnswerCard() {
    return Center(
      child: GestureDetector(
        onTap: () => _handlePdfTap(context, _dummyPdfUrl),
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

  Widget _buildImageAnswerCard() {
    return Center(
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, _dummyImageUrl),
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
                  _dummyImageUrl,
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

  Widget _buildTextAnswerCard() {
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
              color: Colors.black.withValues(alpha: 0.05),
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
                  'Text Answer',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Divider(height: 24.h, color: const Color(0xFFE2E8F0)),
            Text(
              _dummyTextAnswer.trim(),
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    final List<Map<String, String>> dummyComments = [
      {
        'user': 'Rohan Sharma',
        'time': '2h ago',
        'comment':
            'The introduction is quite compelling but could be structured better with more focus on the post-war economic impact.',
        'avatar': 'https://i.pravatar.cc/150?u=rohan',
      },
      {
        'user': 'Sneha Patel',
        'time': '5h ago',
        'comment':
            'Good use of examples, but the conclusion feels a bit rushed. Try to summarize the key points more effectively.',
        'avatar': 'https://i.pravatar.cc/150?u=sneha',
      },
      {
        'user': 'Amit Verma',
        'time': '1d ago',
        'comment':
            'Great analysis! I specifically liked the part where you mentioned the strategic bases. Keep it up!',
        'avatar': 'https://i.pravatar.cc/150?u=amit',
      },
    ];

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PEER REVIEWS (3)',
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyComments.length,
            separatorBuilder: (context, index) => SizedBox(height: 20.h),
            itemBuilder: (context, index) {
              final comment = dummyComments[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: NetworkImage(comment['avatar']!),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              comment['user']!,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              comment['time']!,
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
                          comment['comment']!,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _feedbackController,
                    minLines: 1,
                    maxLines: 5,
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
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
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
    );
  }
}
