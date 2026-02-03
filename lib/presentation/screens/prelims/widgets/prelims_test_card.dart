import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

import '../../../../core/router/args.dart';

class PrelimsTestCard extends StatelessWidget {
  final bool isAttempted;
  final String? lastAttemptedDate;
  final TestModel testModel;
  final bool isEligibleForRetest;
  final bool hasProgress;

  const PrelimsTestCard({
    super.key,
    required this.testModel,
    this.isAttempted = false,
    this.isEligibleForRetest = false,
    this.hasProgress = false,
    this.lastAttemptedDate,
  });

  @override
  Widget build(BuildContext context) {
    return TestModule(
      title: testModel.name,
      fontSize: 20.sp,
      testModel: testModel,
      showShareButton: true,
      testType: TestType.prelims,
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
            if (hasProgress && !isAttempted) ...[
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: AppColors.primary, width: 0.5),
                ),
                child: Text(
                  'RESUME',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
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
                    context.push(
                      AppRoutes.prelimsInstructionsScreen,
                      extra: PrelimsInstructionScreenArgs(
                        testModal: testModel,
                        testId: testModel.id,
                      ),
                    );
                  },
                ),
                8.wGap,
              ],
              _buildSecondaryButton(
                icon: Icons.visibility_outlined,
                label: "Result",
                onTap: () {
                  context.push(
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

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.primary, // Light background for secondary buttons
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            children: [
              Icon(icon, size: 14.sp, color: Colors.white),
              4.wGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
