import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../../core/router/args.dart';

class PrelimsTestCard extends StatelessWidget {
  final bool isAttempted;
  final String? lastAttemptedDate;
  final TestModel testModel;
  final bool isEligibleForRetest;

  const PrelimsTestCard({
    super.key,
    required this.testModel,
    this.isAttempted = false,
    this.isEligibleForRetest = false,
    this.lastAttemptedDate,
  });

  @override
  Widget build(BuildContext context) {
    return TestModule(
      title: testModel.name,
      fontSize: 20.sp,
      testModel: testModel,
      showShareButton: true,
      cards: [
        // Metadata: Questions and Duration
        Row(
          children: [
            _buildMetadataIcon(Icons.quiz_rounded),
            4.wGap,
            Text(
              "${testModel.noQuestions} Questions",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
            16.wGap,
            _buildMetadataIcon(Icons.access_time_filled),
            4.wGap,
            Text(
              "${testModel.duration} min",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        8.hGap,
        // Conditional Footer: Retest and Result
        if (isAttempted) ...[
          12.hGap,
          Divider(thickness: 0.3, color: Colors.grey),
          // 10.hGap,
          Row(
            children: [
              Expanded(
                child: Text(
                  "Last attempt: ${lastAttemptedDate ?? ''}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.gray400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (isEligibleForRetest) ...[
                _buildSecondaryButton(
                  icon: Icons.refresh,
                  label: "Retest",
                  onTap: () {
                    context.pushReplacementNamed(
                      AppRoutes.prelimsInstructionsScreen,
                      extra: PrelimsInstructionScreenArgs(testModal: testModel),
                    );
                  },
                ),
                8.wGap,
              ],
              _buildSecondaryButton(
                icon: Icons.visibility_outlined,
                label: "Result",
                onTap: () {
                  context.pushReplacement(
                    AppRoutes.resultScreen,
                    extra: ResultScreenArgs(
                      isFromTest: false,
                      testModal: testModel,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataIcon(IconData icon) {
    return Icon(icon, size: 14.sp, color: AppColors.gray500);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: textColor),
              6.wGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.gray100, // Light background for secondary buttons
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            children: [
              Icon(icon, size: 14.sp, color: AppColors.gray900),
              4.wGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
