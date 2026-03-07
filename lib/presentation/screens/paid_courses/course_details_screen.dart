import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/purchase/purchase_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/purchase/purchase_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/purchase/purchase_state.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
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
  Map<int, TestAttemptState> _attemptStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAttemptStates();
    context.read<DailyDescTestBloc>().add(
      FetchAllTests(courseId: widget.courseModel.id),
    );
    context.read<PurchaseBloc>().add(FetchPurchases());
  }

  Future<void> _fetchAttemptStates() async {
    final testRepo = getIt<TestRepository>();
    final tests = widget.courseModel.tests;
    final allPrelims = [...?tests?.prelims];

    final Map<int, TestAttemptState> states = {};
    for (final test in allPrelims) {
      final result = await testRepo.fetchTestAttemptState(test.id);
      result.fold((_) {}, (state) => states[test.id] = state);
    }

    if (mounted) {
      setState(() {
        _attemptStates = states;
      });
    }
  }

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
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchAttemptStates,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              final purchases =
                  (state is PurchaseFetched)
                      ? state.purchases
                      : (state is PurchaseSuccess
                          ? state.purchases
                          : (state is PurchasePurchasing
                              ? state.purchases
                              : (state is PurchaseFailed
                                  ? state.purchases
                                  : <UserPurchaseModel>[])));
              final bool isEnrolled = purchases.any(
                (p) => p.courseId == widget.courseModel.id,
              );
              return _bottomBar(isEnrolled);
            },
          ),
        ],
      ),
    );
  }

  bool _hasNoTests() {
    final t = widget.courseModel.tests;
    if (t == null) return true;
    return (t.prelims == null || t.prelims!.isEmpty) &&
        (t.descriptive == null || t.descriptive!.isEmpty);
  }

  Widget _buildAllTests() {
    if (_hasNoTests()) return _buildEmptyState();

    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        final purchases =
            (purchaseState is PurchaseFetched)
                ? purchaseState.purchases
                : (purchaseState is PurchaseSuccess
                    ? purchaseState.purchases
                    : (purchaseState is PurchasePurchasing
                        ? purchaseState.purchases
                        : (purchaseState is PurchaseFailed
                            ? purchaseState.purchases
                            : <UserPurchaseModel>[])));
        final bool isEnrolled = purchases.any(
          (p) => p.courseId == widget.courseModel.id,
        );

        final tests = widget.courseModel.tests;
        final List<Widget> items = [];
        final prelims = tests?.prelims ?? [];
        for (int i = 0; i < prelims.length; i++) {
          items.add(
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildTestItem(
                test: prelims[i],
                index: '${i + 1}',
                isEnrolled: isEnrolled,
              ),
            ),
          );
        }

        final descriptiveTests = tests?.descriptive ?? [];
        if (descriptiveTests.isNotEmpty) {
          final prelimCount = prelims.length;
          items.add(
            BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
              builder: (context, state) {
                final List<Widget> descItems = [];
                final bool isFetching = state is DailyDescTestFetching;
                final Map<int, dynamic> answersMap =
                    (state is DailyDescTestFetched) ? state.answersMap : {};

                for (int i = 0; i < descriptiveTests.length; i++) {
                  final test = descriptiveTests[i];
                  final hasAnswer = answersMap.containsKey(test.id);

                  // Find purchase to get assessment type
                  final purchase = purchases.firstWhere(
                    (p) => p.courseId == widget.courseModel.id,
                    orElse:
                        () => UserPurchaseModel(
                          id: 0,
                          userId: 0,
                          courseId: 0,
                          assessmentType: AssessmentType.single,
                          createdAt: '',
                        ),
                  );

                  descItems.add(
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildDescTestItem(
                        test: test,
                        index: '${prelimCount + i + 1}',
                        hasAnswer: hasAnswer,
                        isEnrolled: isEnrolled,
                        assessmentType:
                            isEnrolled ? purchase.assessmentType : null,
                        isLoading: isFetching,
                      ),
                    ),
                  );
                }
                return Column(children: descItems);
              },
            ),
          );
        }

        return Column(children: items);
      },
    );
  }

  Future<void> _navigateToInstruction(TestModel test) async {
    await context.push(
      AppRoutes.prelimsInstructionsScreen,
      extra: PrelimsInstructionScreenArgs(testId: test.id),
    );
  }

  // // Bottom Bar
  Widget _bottomBar(bool isEnrolled) {
    final bool isPrelims =
        widget.courseModel.testType?.toLowerCase() == 'prelims';
    final bool hasPrice = widget.courseModel.priceSingle != null;
    final bool showPrice = !isEnrolled && isPrelims && hasPrice;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment:
              showPrice
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
          children: [
            if (showPrice)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "₹${widget.courseModel.priceSingle}",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            isEnrolled
                ? Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                          size: 20.sp,
                        ),
                        8.wGap,
                        Text(
                          "Enrolled",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : (showPrice
                    ? ElevatedButton(
                      onPressed: () => _handleEnrollment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        "Enroll Now",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleEnrollment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          "Enroll Now",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEnrollment(BuildContext context) async {
    final hasDescriptive =
        widget.courseModel.tests?.descriptive != null &&
        widget.courseModel.tests!.descriptive!.isNotEmpty;

    AssessmentType? selectedType;
    if (hasDescriptive) {
      selectedType = await context.push<AssessmentType>(
        AppRoutes.assessmentTypeSelection,
        extra: AssessmentTypeSelectionScreenArgs(
          courseModel: widget.courseModel,
        ),
      );
    } else {
      selectedType = AssessmentType.single;
    }

    if (selectedType != null) {
      if (!mounted) return;
      context.read<PurchaseBloc>().add(
        PurchaseCourse(
          UserPurchasePayload(
            userId: 0, // Handled internally in SupabaseHelper
            courseId: widget.courseModel.id,
            assessmentType: selectedType,
          ),
        ),
      );
    }
  }

  Widget _buildTestItem({
    required TestModel test,
    required String index,
    required bool isEnrolled,
  }) {
    final bool isPrelims = test.testType == TestType.prelims;
    final Color badgeColor =
        isPrelims ? const Color(0xFF059669) : AppColors.primary;
    final String badgeLabel = 'Prelims';
    final String details =
        "${test.noQuestions} Questions • ${test.duration} Minutes";

    final attemptState = _attemptStates[test.id];
    final bool isCompleted =
        attemptState != null &&
        attemptState.attemptsDone >= attemptState.maxAttempts;
    final bool hasAttempted =
        attemptState != null && attemptState.attemptsDone > 0;

    Widget? statusWidget;
    if (isCompleted) {
      statusWidget = _buildStatusBadge(
        icon: Icons.check_circle_rounded,
        label: 'Completed',
        color: const Color(0xFF059669),
      );
    } else if (hasAttempted) {
      if (attemptState.canRetry) {
        statusWidget = _buildStatusBadge(
          icon: Icons.replay_rounded,
          label:
              'Attempt ${attemptState.attemptsDone}/${attemptState.maxAttempts} • Retry available',
          color: const Color(0xFFD97706),
        );
      } else {
        final remaining = _formatRemainingTime(attemptState.retryAvailableAt);
        statusWidget = _buildStatusBadge(
          icon: Icons.hourglass_top_rounded,
          label:
              'Attempt ${attemptState.attemptsDone}/${attemptState.maxAttempts} • Retry after $remaining',
          color: const Color(0xFFD97706),
        );
      }
    }

    return InkWell(
      onTap: () async {
        if (!isEnrolled) {
          getIt<SnackBarHelper>().showError(
            "Please enroll in the course to access tests.",
          );
          return;
        }
        if (isCompleted) {
          // Navigate to result screen
          await context.push(
            AppRoutes.resultScreen,
            extra: ResultScreenArgs(isFromTest: false, testModal: test),
          );
          _fetchAttemptStates();
        } else if (hasAttempted && !attemptState.canRetry) {
          // In cooldown — show last result
          await context.push(
            AppRoutes.resultScreen,
            extra: ResultScreenArgs(isFromTest: false, testModal: test),
          );
          _fetchAttemptStates();
        } else {
          await _navigateToInstruction(test);
          if (!mounted) return;
          _fetchAttemptStates();
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
        statusWidget: statusWidget,
        isLocked: !isEnrolled,
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          4.wGap,
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(String? retryAvailableAt) {
    if (retryAvailableAt == null || retryAvailableAt.isEmpty) return 'soon';
    try {
      final retryAt = DateTime.parse(retryAvailableAt);
      final now = DateTime.now().toUtc();
      final diff = retryAt.difference(now);
      if (diff.isNegative) return 'now';
      if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
      return '${diff.inMinutes}m';
    } catch (_) {
      return 'soon';
    }
  }

  Widget _buildDescTestItem({
    required DescTestModel test,
    required String index,
    required bool hasAnswer,
    required bool isEnrolled,
    AssessmentType? assessmentType,
    bool isLoading = false,
  }) {
    const Color badgeColor = Color(0xFF7C3AED);
    final String badgeLabel =
        assessmentType != null ? assessmentType.type : 'Descriptive';
    final String details = "${test.noQuestions} Questions";

    Widget? statusWidget;
    if (hasAnswer) {
      statusWidget = _buildStatusBadge(
        icon: Icons.check_circle_rounded,
        label: 'Completed',
        color: const Color(0xFF059669),
      );
    }

    return InkWell(
      onTap: () async {
        if (!isEnrolled) {
          getIt<SnackBarHelper>().showError(
            "Please enroll in the course to access tests.",
          );
          return;
        }
        if (hasAnswer) {
          getIt<SnackBarHelper>().showSuccess(
            "This test has already been attempted!",
          );
          return;
        }
        await context.push(
          AppRoutes.descFullQuestions,
          extra: DescFullQuestionsScreenArgs(
            testId: test.id,
            testName: test.name,
            courseId: widget.courseModel.id,
          ),
        );
        // Refresh submission status after returning
        if (!mounted) return;
        context.read<DailyDescTestBloc>().add(
          FetchAllTests(courseId: widget.courseModel.id),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
        statusWidget: statusWidget,
        isLocked: !isEnrolled,
      ),
    );
  }

  Widget _testItemContainer({
    required String index,
    required String name,
    required String details,
    required String badgeLabel,
    required Color badgeColor,
    Widget? statusWidget,
    bool isLocked = false,
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
                        color: badgeColor.withAlpha(26),
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
                if (statusWidget != null) statusWidget,
              ],
            ),
          ),
          isLocked
              ? Icon(
                Icons.lock_rounded,
                color: Colors.grey.shade400,
                size: 20.sp,
              )
              : Icon(
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
