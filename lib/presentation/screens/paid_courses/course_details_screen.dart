import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

class CourseDetailsScreen extends StatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseModel});

  final CourseModel courseModel;

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        ),
        title: Text(
          "Course Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: 20.h,
                top: 10.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.courseModel.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  24.hGap,

                  // Key Highlights
                  Text(
                    "Key Highlights",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  16.hGap,
                  Row(
                    children: [
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.analytics_outlined,
                          title: "Detailed Analytics",
                          subtitle: "Track every weak point",
                        ),
                      ),
                      12.wGap,
                      Expanded(
                        child: _buildHighlightCard(
                          icon: Icons.bar_chart_rounded,
                          title: "Real Time Rank",
                          subtitle: "Outperform your peers",
                        ),
                      ),
                    ],
                  ),
                  32.hGap,

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  8.hGap,
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final String descriptionText =
                          widget.courseModel.description;
                      final TextStyle style = TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B), // Slate 500
                        height: 1.5,
                      );

                      final span = TextSpan(
                        text: descriptionText,
                        style: style,
                      );
                      final tp = TextPainter(
                        text: span,
                        maxLines: 4,
                        textDirection: TextDirection.ltr,
                      );
                      tp.layout(maxWidth: constraints.maxWidth);
                      final bool isOverflowing = tp.didExceedMaxLines;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            descriptionText,
                            style: style,
                            maxLines: _isExpanded ? null : 4,
                            overflow:
                                _isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                          ),
                          if (isOverflowing) ...[
                            4.hGap,
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? "Read Less" : "Read More",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  32.hGap,
                  Text(
                    "Test Series",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  16.hGap,
                  _buildAllTests(),

                  // Test Series List
                ],
              ),
            ),
          ),

          // // Bottom Bar
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border(top: BorderSide(color: Colors.grey.shade200)),
          //   ),
          //   child: SafeArea(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Column(
          //           mainAxisSize: MainAxisSize.min,
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "Total Price",
          //               style: TextStyle(
          //                 fontSize: 10.sp,
          //                 color: Colors.grey.shade600,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             4.hGap,
          //             Row(
          //               crossAxisAlignment: CrossAxisAlignment.baseline,
          //               textBaseline: TextBaseline.alphabetic,
          //               children: [
          //                 Text(
          //                   "Free",
          //                   style: TextStyle(
          //                     fontSize: 22.sp,
          //                     fontWeight: FontWeight.w900,
          //                     color: const Color(0xFF111827),
          //                   ),
          //                 ),
          //                 8.wGap,
          //                 Text(
          //                   "₹500",
          //                   style: TextStyle(
          //                     fontSize: 12.sp,
          //                     fontWeight: FontWeight.w500,
          //                     color: Colors.grey.shade400,
          //                     decoration: TextDecoration.lineThrough,
          //                     decorationColor: Colors.grey.shade400,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //         ElevatedButton(
          //           onPressed: () {},
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: AppColors.primary,
          //             foregroundColor: Colors.white,
          //             elevation: 0,
          //             padding: EdgeInsets.symmetric(
          //               horizontal: 48.w,
          //               vertical: 14.h,
          //             ),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8.r),
          //             ),
          //           ),
          //           child: Text(
          //             "Buy Now",
          //             style: TextStyle(
          //               fontSize: 14.sp,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.sp),
          ),
          12.hGap,
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          4.hGap,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasNoTests() {
    final t = widget.courseModel.tests;
    return (t.mcq == null || t.mcq!.isEmpty) &&
        (t.prelims == null || t.prelims!.isEmpty) &&
        (t.descriptive == null || t.descriptive!.isEmpty);
  }

  Widget _buildAllTests() {
    if (_hasNoTests()) return _buildEmptyState();

    final tests = widget.courseModel.tests;
    final List<Widget> items = [];
    int counter = 1;

    for (final test in tests.mcq ?? []) {
      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildTestItem(test: test, index: '$counter'),
        ),
      );
      counter++;
    }

    for (final test in tests.prelims ?? []) {
      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildTestItem(test: test, index: '$counter'),
        ),
      );
      counter++;
    }

    for (final test in tests.descriptive ?? []) {
      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildDescTestItem(test: test, index: '$counter'),
        ),
      );
      counter++;
    }

    return Column(children: items);
  }

  void _navigateToInstruction(TestModel test) {
    switch (test.testType) {
      case TestType.mcq:
        context.push(
          AppRoutes.mcqTestInstructionScreen,
          extra: TestInstructionScreenArgs(testId: test.id),
        );
        break;
      case TestType.prelims:
        context.push(
          AppRoutes.prelimsInstructionsScreen,
          extra: PrelimsInstructionScreenArgs(testId: test.id),
        );
        break;
      case TestType.desc:
        context.push(
          AppRoutes.descriptiveTestInstructionScreen,
          extra: DescTestInstructionScreenArgs(testId: test.id),
        );
        break;
    }
  }

  Widget _buildTestItem({required TestModel test, required String index}) {
    final bool isPrelims = test.testType == TestType.prelims;
    final Color badgeColor =
        isPrelims ? const Color(0xFF059669) : AppColors.primary;
    final String badgeLabel = isPrelims ? 'Prelims' : 'MCQ';
    final String details =
        "${test.noQuestions} Questions • ${test.duration} Minutes";

    return InkWell(
      onTap: () => _navigateToInstruction(test),
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
      ),
    );
  }

  Widget _buildDescTestItem({
    required DescTestModel test,
    required String index,
  }) {
    const Color badgeColor = Color(0xFF7C3AED);
    const String badgeLabel = 'Descriptive';
    final String details = "${test.noQuestions} Questions";

    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.descriptiveTestInstructionScreen,
          extra: DescTestInstructionScreenArgs(testId: test.id),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
      ),
    );
  }

  Widget _testItemContainer({
    required String index,
    required String name,
    required String details,
    required String badgeLabel,
    required Color badgeColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text(
              index,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          12.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                4.hGap,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    6.wGap,
                    Text(
                      details,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey.shade400,
            size: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slate 50
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 48.sp,
            color: AppColors.primary.withAlpha(50),
          ),
          16.hGap,
          Text(
            "Tests Coming Soon",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          8.hGap,
          Text(
            "We are preparing high-quality tests for this course. Stay tuned!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
