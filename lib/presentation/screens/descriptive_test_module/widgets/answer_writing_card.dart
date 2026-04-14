import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AnswerWritingCard extends StatelessWidget {
  final DescTestModel descTestModel;
  final VoidCallback onStartTestTap;
  final VoidCallback onShareTap;
  final bool isUnlocked;
  final bool isAttempted;
  final VoidCallback onReviewTap;

  const AnswerWritingCard({
    super.key,
    required this.descTestModel,
    required this.onStartTestTap,
    required this.onShareTap,
    this.isUnlocked = true,
    this.isAttempted = false,
    required this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedContainer(
      padding: EdgeInsets.all(20.w),
      borderRadius: 25.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Share Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  descTestModel.name,
                  style: AppTexts.titleTextStyle.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              10.wGap,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onShareTap,
                  icon: Icon(
                    AppIcons.shareTest,
                    size: 20.sp,
                    color: AppColors.gray700,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          8.hGap,
          // Metadata: Questions and Marks
          Row(
            children: [
              Icon(Icons.style_outlined, size: 16.sp, color: AppColors.gray500),
              4.wGap,
              Text(
                "${descTestModel.noQuestions} Questions",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  "•",
                  style: TextStyle(color: AppColors.gray400, fontSize: 14.sp),
                ),
              ),
              Icon(
                Icons.workspace_premium_outlined,
                size: 16.sp,
                color: AppColors.gray500,
              ),
              4.wGap,
              Text(
                "${descTestModel.totalMarks} Marks",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          20.hGap,
          // Action Buttons
          Row(
            children: [
              // Start Test / Review Button
              Expanded(
                child: _buildActionButton(
                  onTap: onStartTestTap,
                  icon: AppIcons.startTest,
                  label: "Start Test",
                  isDisabled: isAttempted,
                ),
              ),
              10.wGap,
              // Answer Key Button
              Expanded(
                child: _buildActionButton(
                  onTap: onReviewTap,
                  icon: Icons.rate_review_outlined,
                  label: "Review",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    bool isDisabled = false,
  }) {
    return Material(
      color: isDisabled ? AppColors.gray200 : AppColors.primary.withAlpha(240),
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDisabled ? AppColors.gray500 : Colors.white,
                size: 18.sp,
              ),
              8.wGap,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDisabled ? AppColors.gray500 : Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
