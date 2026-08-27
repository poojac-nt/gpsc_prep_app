import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class QuestionTile extends StatelessWidget {
  final int index;
  final String questionText;
  final VoidCallback onTap;

  const QuestionTile({
    super.key,
    required this.index,
    required this.questionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'questionNumber$index',
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            10.wGap,
            Expanded(
              child: Text(
                questionText,
                style: AppTexts.subTitle.copyWith(
                  fontSize: 17.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _animatedArrow(),
          ],
        ),
      ),
    ).padAll(AppPaddings.appPaddingInt);
  }

  Widget _animatedArrow() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) => Transform.translate(
        offset: Offset(4 * value, 0),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: AppColors.primary,
          shadows: [
            Shadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
