import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../widgets/action_button.dart';

class DescriptiveTestResultScreen extends StatelessWidget {
  const DescriptiveTestResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Name", style: AppTexts.titleTextStyle)),
      body: SingleChildScrollView(
        child: ElevatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Center(
            child: Column(
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
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                14.hGap,
                Text(
                  textAlign: TextAlign.center,
                  "Your descriptive test has been submitted to mentors for evaluation. You will receive detailed feedback once the evaluation is complete.",
                  style: AppTexts.labelTextStyle.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
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
                      9.hGap,
                      _buildInstructionTile("Mentors will review your answers"),
                      3.hGap,
                      _buildInstructionTile(
                        "You'll receive detailed feedback and marks",
                      ),
                      3.hGap,
                      _buildInstructionTile(
                        "Check your results in the reports section",
                      ),
                    ],
                  ),
                ),
                20.hGap,
                ActionButton(
                  backgroundColor: AppColors.primary,
                  text: "Back to Dashboard",
                  onTap: () {},
                  fontColor: Colors.white,
                ),
                // 15.wGap,
                // Flexible(
                //   child: ActionButton(
                //     isFullWidth: false,
                //     padding: EdgeInsets.symmetric(
                //       vertical: 9.h,
                //       horizontal: 20.w,
                //     ),
                //     text: "View Reports",
                //     borderColor: Colors.black,
                //     fontColor: Colors.black,
                //     backgroundColor: Colors.white,
                //     onTap: () {},
                //   ),
                // ),
              ],
            ),
          ),
        ).padAll(15),
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
