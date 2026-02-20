import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestStatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? lastAttemptDate;
  final int? hoursRemaining;
  final bool isLimitReached;

  const TestStatusDialog({
    super.key,
    required this.title,
    required this.message,
    this.lastAttemptDate,
    this.hoursRemaining,
    required this.isLimitReached,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Icon
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(20)),
            child: Icon(
              isLimitReached ? Icons.lock_clock_rounded : Icons.timer_outlined,
              size: 48.sp,
              color: AppColors.primary,
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTexts.heading.copyWith(color: AppColors.primary),
                ),
                12.hGap,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTexts.subTitle.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                if (lastAttemptDate != null || hoursRemaining != null) ...[
                  20.hGap,
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        if (lastAttemptDate != null)
                          _buildInfoRow(
                            Icons.calendar_today_rounded,
                            "Last Attempt",
                            lastAttemptDate!,
                          ),
                        if (hoursRemaining != null && hoursRemaining! > 0) ...[
                          8.hGap,
                          _buildInfoRow(
                            Icons.hourglass_empty_rounded,
                            "Available In",
                            "$hoursRemaining hour(s)",
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                24.hGap,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Got it",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        12.wGap,
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        8.wGap,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
