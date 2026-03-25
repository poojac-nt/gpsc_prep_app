import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback onSecondaryPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.onSecondaryPressed,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor = Colors.orange,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: iconBgColor ??
                    (iconColor?.withValues(alpha: 0.1) ??
                        Colors.orange.withValues(alpha: 0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: iconColor,
              ),
            ),
            16.hGap,
            // Title
            Text(
              title,
              style: AppTexts.titleTextStyle.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            10.hGap,
            // Description
            Text(
              description,
              style: AppTexts.labelTextStyle.copyWith(
                color: Colors.grey[700],
                fontSize: 14.sp,
                height: 1.5,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            24.hGap,
            // Actions
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: secondaryButtonText,
                    onTap: onSecondaryPressed,
                    backgroundColor: Colors.white,
                    fontColor: Colors.black,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                12.wGap,
                Expanded(
                  child: ActionButton(
                    text: primaryButtonText,
                    onTap: onPrimaryPressed,
                    backgroundColor: AppColors.primary,
                    fontColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
