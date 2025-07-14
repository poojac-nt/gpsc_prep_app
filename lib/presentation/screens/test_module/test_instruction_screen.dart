import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/action_button.dart';

class TestInstructionScreen extends StatefulWidget {
  const TestInstructionScreen({super.key, required this.testId});
  final int testId;

  @override
  State<TestInstructionScreen> createState() => _TestInstructionScreenState();
}

class _TestInstructionScreenState extends State<TestInstructionScreen> {
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daily Test - General Studies",
          style: AppTexts.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: TestModule(
          title: "Test Instructions",
          prefixIcon: Icons.menu_book_outlined,
          cards: [
            BorderedContainer(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              radius: BorderRadius.zero,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "25",
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
                      "30",
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
            10.hGap,
            BorderedContainer(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              radius: BorderRadius.zero,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "1",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Mark Each", style: AppTexts.subTitle),
                  ],
                ),
              ),
            ),
            10.hGap,
            Text("Instructions: ", style: AppTexts.labelTextStyle),
            10.hGap,
            _buildInstructionTile(
              "This test contains 25 multiple choice questions",
            ),
            3.hGap,
            _buildInstructionTile("There is no negative marking"),
            3.hGap,
            _buildInstructionTile(
              "You can navigate between questions using next/previous buttons",
            ),
            3.hGap,
            _buildInstructionTile("Click to Submit to finish test"),
            15.hGap,
            10.hGap,
            Text("Choose Language", style: AppTexts.labelTextStyle),
            10.hGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _languageButton(context, 'Hindi', 'hi'),
                _languageButton(context, 'English', 'en'),
                _languageButton(context, 'Gujarati', 'gj'),
              ],
            ),
            15.hGap,
            ActionButton(
              text: "Start Test",
              onTap: () {
                context.push(
                  AppRoutes.testScreen,
                  extra: TestScreenArgs(
                    isFromResult: false,
                    testId: widget.testId,
                    language: selectedLanguage,
                  ), // or testId: 123
                );
              },
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
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
    final bool isSelected = selectedLanguage == code;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade100 : null,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      onPressed: () {
        setState(() {
          selectedLanguage = code;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
