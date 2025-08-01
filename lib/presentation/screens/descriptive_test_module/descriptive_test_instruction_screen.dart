import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/action_button.dart';
import '../../widgets/bordered_container.dart';
import '../../widgets/elevated_container.dart';

class DescriptiveTestInstructionScreen extends StatefulWidget {
  const DescriptiveTestInstructionScreen({super.key});

  @override
  State<DescriptiveTestInstructionScreen> createState() =>
      _DescriptiveTestInstructionScreenState();
}

class _DescriptiveTestInstructionScreenState
    extends State<DescriptiveTestInstructionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Name", style: AppTexts.titleTextStyle)),
      body: SingleChildScrollView(
        child: ElevatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Test Instructions",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                20.hGap,
                BorderedContainer(
                  padding: EdgeInsets.all(AppPaddings.defaultPadding),
                  radius: BorderRadius.zero,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          5.toString(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Questions",
                          style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ),
                10.hGap,
                BorderedContainer(
                  padding: EdgeInsets.all(AppPaddings.defaultPadding),
                  radius: BorderRadius.zero,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          10.toString(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Minutes",
                          style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                        ),
                      ],
                    ),
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
                        "Important Instructions:",
                        style: AppTexts.labelTextStyle,
                      ),
                      9.hGap,
                      _buildInstructionTile(
                        "Read each question carefully and plan your answer before writing",
                      ),
                      5.hGap,
                      _buildInstructionTile(
                        "Each question has suggested time limits - manage your time wisely",
                      ),
                      5.hGap,
                      _buildInstructionTile(
                        "Your answers will be sent to mentors for evaluation",
                      ),
                      5.hGap,
                      _buildInstructionTile(
                        "Make sure to submit before time expires",
                      ),
                    ],
                  ),
                ),
                20.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _languageButton(context, "English", "en"),
                    _languageButton(context, "Gujarati", "en"),
                    _languageButton(context, "Hindi", "en"),
                  ],
                ),
                20.hGap,
                ActionButton(
                  backgroundColor: AppColors.primary,
                  text: "Start Test",
                  onTap: () {
                    context.pushReplacement(AppRoutes.descriptiveTestScreen);
                  },
                  fontColor: Colors.white,
                ),
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

Widget _languageButton(BuildContext context, String label, String code) {
  final bool isSelected = false;
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: isSelected ? Colors.blue.shade100 : null,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey, width: 2),
    ),
    onPressed: () {},
    child: Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.blue : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}
