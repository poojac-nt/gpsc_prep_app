import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

import '../../../../core/router/args.dart';

class TestCard extends StatelessWidget {
  final bool isAttempted;
  final String? lastAttemptedDate;
  final TestModel? testModel;
  final DescTestModel? descTestModel;
  final bool isEligibleForRetest;
  final bool showFooter;
  final Widget? trailing;

  const TestCard({
    super.key,
    this.testModel,
    this.descTestModel,
    this.isAttempted = false,
    this.isEligibleForRetest = false,
    this.lastAttemptedDate,
    this.showFooter = true,
    this.trailing,
  }) : assert(testModel != null || descTestModel != null);

  @override
  Widget build(BuildContext context) {
    final String title = testModel?.name ?? descTestModel?.name ?? "";
    final int noQuestions =
        testModel?.noQuestions ?? descTestModel?.noQuestions ?? 0;
    final int? duration = testModel?.duration;
    final int? totalMarks = testModel?.totalMarks ?? descTestModel?.totalMarks;

    return TestModule(
      title: title,
      fontSize: 20.sp,
      testModel: testModel,
      descTestModel: descTestModel,
      showShareButton: true,
      testType:
          descTestModel != null
              ? TestType.desc
              : (testModel?.testType ?? TestType.mcq),
      trailing: trailing,
      cards: [
        // Metadata: Questions and Duration/Marks
        Row(
          children: [
            _buildMetadataIcon(Icons.quiz_rounded),
            4.wGap,
            Text(
              "$noQuestions Questions",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
            if (duration != null) ...[
              16.wGap,
              _buildMetadataIcon(Icons.access_time_filled),
              4.wGap,
              Text(
                "$duration min",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ] else if (totalMarks != null) ...[
              16.wGap,
              _buildMetadataIcon(Icons.grade_rounded),
              4.wGap,
              Text(
                "$totalMarks Marks",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ],
        ),
        if (showFooter && isAttempted) ...[
          8.hGap,
          12.hGap,
          Divider(thickness: 0.3, color: Colors.grey),
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
              if (isEligibleForRetest && testModel != null) ...[
                _buildSecondaryButton(
                  icon: Icons.refresh,
                  label: "Retest",
                  onTap: () {
                    context.push(
                      AppRoutes.mcqTestInstructionScreen,
                      extra: TestInstructionScreenArgs(
                        testModal: testModel!,
                        testId: testModel!.id,
                      ),
                    );
                  },
                ),
                8.wGap,
              ],
              if (testModel != null)
                _buildSecondaryButton(
                  icon: Icons.visibility_outlined,
                  label: "Result",
                  onTap: () {
                    context.push(
                      AppRoutes.resultScreen,
                      extra: ResultScreenArgs(
                        isFromTest: false,
                        testModal: testModel!,
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
