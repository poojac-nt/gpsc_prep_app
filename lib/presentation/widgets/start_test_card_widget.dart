import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/dashboard_container.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/icon_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_painter.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class StartTestCard extends StatelessWidget {
  final Color color;
  final String buttonText;
  final String title;
  final String subTitle;
  final Color buttonTextColor;
  final Color buttonBgColor;
  final VoidCallback onTap;

  const StartTestCard({
    super.key,
    required this.color,
    this.buttonText = 'Start Test',
    required this.title,
    required this.subTitle,
    this.buttonTextColor = Colors.white,
    this.buttonBgColor = const Color(0xff3b82f6),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppBorders.dashboardBorderRadius,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.hGap,
                  IconContainer(
                    borderRadius: BorderRadius.circular(100.r),
                    icon: Icons.menu_book,
                    color: color,
                  ),
                  10.hGap,
                  Text(title, style: AppTexts.dashboardMediumTitle),
                  5.hGap,
                  Text(subTitle, style: AppTexts.dashboardSmallTexts),
                  8.hGap,
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      foregroundColor: buttonTextColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 13.w,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          4.wGap,
                          Icon(Icons.navigate_next, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  5.hGap,
                ],
              ),
            ),
            Positioned(
              top: -10.h,
              right: -10.w,
              child: SizedBox(
                width: 120.w,
                height: 120.h,
                child: CustomPaint(painter: CirclePainter(color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
