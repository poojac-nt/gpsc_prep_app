import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:markdown_widget/markdown_widget.dart';

class QuestionDetailCard extends StatefulWidget {
  final DescQuestionModel question;
  final int index;
  final int commentCount;
  final String selectedLanguage;
  final bool isUnlocked;
  const QuestionDetailCard({
    super.key,
    required this.question,
    required this.index,
    this.commentCount = 0,
    this.selectedLanguage = 'en',
    this.isUnlocked = true,
  });

  @override
  State<QuestionDetailCard> createState() => _QuestionDetailCardState();
}

class _QuestionDetailCardState extends State<QuestionDetailCard> {
  bool _isModelAnswerExpanded = false;

  DescQuestionLanguageData get _currentLanguageData {
    if (widget.selectedLanguage == 'hi' && widget.question.questionHi != null) {
      return widget.question.questionHi!;
    } else if (widget.selectedLanguage == 'gj' &&
        widget.question.questionGj != null) {
      return widget.question.questionGj!;
    }
    return widget.question.questionEn;
  }

  @override
  Widget build(BuildContext context) {
    final languageData = _currentLanguageData;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageData.questionTxt,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          const Divider(color: Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (!widget.isUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Model answer is locked and will be available soon.',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _isModelAnswerExpanded = !_isModelAnswerExpanded;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color:
                          widget.isUnlocked
                              ? const Color(0xFF4F46E5)
                              : Colors.grey,
                      size: 18.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Model Answer',
                      style: TextStyle(
                        color:
                            widget.isUnlocked
                                ? const Color(0xFF4F46E5)
                                : Colors.grey,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      _isModelAnswerExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color:
                          widget.isUnlocked
                              ? const Color(0xFF4F46E5)
                              : Colors.grey,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isModelAnswerExpanded) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: MarkdownWidget(
                data: languageData.answerTxt,
                shrinkWrap: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
