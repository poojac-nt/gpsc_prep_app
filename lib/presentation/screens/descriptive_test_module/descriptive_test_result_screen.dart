import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../utils/enums/user_role.dart';
import '../../widgets/action_button.dart';

class DescriptiveTestResultScreen extends StatelessWidget {
  const DescriptiveTestResultScreen({super.key, required this.testName});
  final String testName;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final role = getIt<CacheManager>().getUserRole();
        if (role == UserRole.admin) {
          context.go(AppRoutes.adminDashboard);
        } else if (role == UserRole.mentor) {
          context.go(AppRoutes.mentorDashboard);
        } else {
          context.go(AppRoutes.studentDashboard);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(testName, style: AppTexts.titleTextStyle),
          ),
        ),
        body: IntrinsicHeight(
          child: ElevatedContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 38.sp,
                  color: Colors.green,
                ),
                10.hGap,
                Text(
                  "Test Submitted Successfully!",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.hGap,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 15.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: AppBorders.borderRadius,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "What happens next?",
                        style: AppTexts.labelTextStyle,
                      ),
                      3.hGap,
                      _buildInstructionTile(
                        "Please Compare your answers with the model answers provided after 5 pm.",
                      ),
                    ],
                  ),
                ),
                20.hGap,
                ActionButton(
                  backgroundColor: AppColors.primary,
                  text: "Back to Dashboard",
                  onTap: () {
                    final role = getIt<CacheManager>().getUserRole();
                    if (role == UserRole.admin) {
                      context.go(AppRoutes.adminDashboard);
                    } else if (role == UserRole.mentor) {
                      context.go(AppRoutes.mentorDashboard);
                    } else {
                      context.go(AppRoutes.studentDashboard);
                    }
                  },
                  fontColor: Colors.white,
                ),
              ],
            ),
          ).padAll(AppPaddings.defaultPadding),
        ),
      ),
    );
  }
}

Widget _buildInstructionTile(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Icon(Icons.circle, size: 6.sp),
      ),
      10.wGap,
      Expanded(
        child: Text(
          maxLines: 3,
          overflow: TextOverflow.visible,
          text,
          style: AppTexts.subTitle.copyWith(color: Colors.black),
        ),
      ),
    ],
  );
}
