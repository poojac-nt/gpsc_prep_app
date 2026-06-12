import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/models/payloads/user_purchase_payload.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/mains_test_review_model.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/domain/entities/user_purchase_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_course_details/fetch_course_details_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/purchase/purchase_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

import '../../../domain/entities/desc_answer_model.dart';

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
    context.read<FetchCourseDetailsBloc>().add(
      FetchCourseTestsAndResults(widget.courseModel.id),
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
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        ),
        title: Text(
          "Course Details",
          style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
        ),
        elevation: 0,
        backgroundColor: AppColors.scaffoldColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocListener<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state is IapPurchaseSuccess) {
            getIt<SnackBarHelper>().showSuccess(
              'Payment successful! You are now enrolled.',
            );
          } else if (state is IapPurchaseFailed &&
              state.message != 'Purchase was cancelled.') {
            getIt<SnackBarHelper>().showError(state.message);
          } else if (state is PurchaseFailed) {
            getIt<SnackBarHelper>().showError(
              'Enrollment failed. Please try again.',
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await _fetchAttemptStates();
                  if (mounted) {
                    context.read<FetchCourseDetailsBloc>().add(
                      FetchCourseTestsAndResults(widget.courseModel.id),
                    );
                  }
                },
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
                        style: AppTexts.titleTextStyle.copyWith(
                          fontSize: 24.sp,
                          height: 1.2,
                        ),
                      ),
                      24.hGap,
                      // Description
                      Text(
                        "About this course",
                        style: AppTexts.heading.copyWith(fontSize: 16.sp),
                      ),
                      12.hGap,
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final String descriptionText =
                              widget.courseModel.description;
                          final TextStyle style = TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.gray500,
                            height: 1.6,
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
                        "Curriculum",
                        style: AppTexts.heading.copyWith(fontSize: 16.sp),
                      ),
                      16.hGap,
                      _buildAllTests(),
                    ],
                  ),
                ),
              ),
            ),
            BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                final bool isEnrolled = state.isCourseEnrolled(
                  widget.courseModel.id,
                );
                final bool isIapLoading = state is IapPurchasing;
                return _bottomBar(isEnrolled, isLoading: isIapLoading);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTests() {
    if (_hasNoTests()) return _buildEmptyState();

    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        final int courseId = widget.courseModel.id;

        final tests = widget.courseModel.tests;

        final List<Widget> items = [];
        final prelims = tests?.prelims ?? [];
        for (int i = 0; i < prelims.length; i++) {
          final test = prelims[i];

          final bool isAccessible = purchaseState.isTestAccessible(
            courseId,
            test.id,
          );
          items.add(
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildTestItem(
                test: test,
                index: '${i + 1}',
                isAccessible: isAccessible,
              ),
            ),
          );
        }

        final descriptiveTests = tests?.descriptive ?? [];
        if (descriptiveTests.isNotEmpty) {
          final prelimCount = prelims.length;

          items.add(
            BlocBuilder<FetchCourseDetailsBloc, FetchCourseDetailsState>(
              builder: (context, state) {
                if (state is FetchCourseDetailsLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final List<Widget> descItems = [];
                final Map<int, List<DescAnswerModel>> answersMap =
                    (state is FetchCourseDetailsSuccess)
                        ? state.answersMap
                        : {};
                final Map<int, MainsTestReviewModel?> reviewModels =
                    (state is FetchCourseDetailsSuccess)
                        ? state.reviewsMap
                        : {};

                for (int i = 0; i < descriptiveTests.length; i++) {
                  final test = descriptiveTests[i];
                  final hasAnswer = answersMap.containsKey(test.id);

                  final bool isAccessible = purchaseState.isTestAccessible(
                    courseId,
                    test.id,
                  );

                  // Find the matching purchase to get assessmentType.
                  final purchase = purchaseState.purchases.firstWhere(
                    (p) => p.courseId == courseId && p.isTestUnlocked(test.id),
                    orElse:
                        () => UserPurchaseModel(
                          id: 0,
                          userId: 0,
                          courseId: 0,
                          testIds: '',
                          assessmentType: AssessmentType.single,
                          createdAt: '',
                          isActive: true,
                        ),
                  );

                  descItems.add(
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildDescTestItem(
                        test: test,
                        index: '${prelimCount + i + 1}',
                        hasAnswer: hasAnswer,
                        isAccessible: isAccessible,
                        assessmentType:
                            isAccessible ? purchase.assessmentType : null,
                        reviewModel: reviewModels[test.id],
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

  Widget _buildDescTestItem({
    required DescTestModel test,
    required String index,
    required bool hasAnswer,
    required bool isAccessible,
    AssessmentType? assessmentType,
    MainsTestReviewModel? reviewModel,
  }) {
    final bool isCourseFree =
        widget.courseModel.singleProduct.productId == ProductIds.freeCourse;
    const Color badgeColor = Color(0xFF7C3AED);
    final String badgeLabel =
        assessmentType != null ? assessmentType.type : 'Descriptive';
    final String details = "${test.noQuestions} Questions";

    Widget? statusWidget;
    if (isAccessible && hasAnswer) {
      String status = "Submitted";
      Color statusColor = const Color(0xFFD97706); // Amber
      IconData statusIcon = Icons.pending_actions_rounded;

      if (reviewModel != null && reviewModel.mentorReviews.isNotEmpty) {
        // Find if any is completed
        final completedReview = reviewModel.mentorReviews.any(
          (m) => m.status.toLowerCase() == "completed",
        );
        if (completedReview) {
          status = "Reviewed";
          statusColor = const Color(0xFF059669); // Green
          statusIcon = Icons.check_circle_rounded;
        } else {
          status = "Under Review";
        }
      }

      statusWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadge(
            icon: statusIcon,
            label: status,
            color: statusColor,
          ),
          10.hGap,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                8.wGap,
                Text(
                  "View Model Answer",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap:
          isAccessible
              ? () async {
                if (hasAnswer) {
                  // No mentor assigned at all
                  if (reviewModel == null ||
                      reviewModel.mentorReviews.isEmpty) {
                    getIt<SnackBarHelper>().showSuccess(
                      "No mentor has been assigned yet. Please wait.",
                    );
                  } else {
                    final reviews = reviewModel.mentorReviews;

                    if (reviews.length == 1) {
                      final mentor = reviews.first;
                      final isCompleted =
                          mentor.status.toLowerCase() == "completed";
                      if (isCompleted) {
                        await context.push(
                          AppRoutes.studentEvaluationResult,
                          extra: StudentEvaluationResultScreenArgs(
                            testId: test.id,
                            testName: test.name,
                            studentName:
                                getIt<CacheManager>().user?.name ?? 'Student',
                            reviewModel: reviewModel,
                            mentorId: mentor.mentorId,
                            courseId: widget.courseModel.id,
                          ),
                        );
                        return;
                      } else {
                        // Assigned but not yet reviewed
                        getIt<SnackBarHelper>().showSuccess(
                          "Your test is assigned to a mentor and is under review. Result will be available soon.",
                        );
                      }
                    } else {
                      // 2+ mentors — always show bottom sheet regardless of status
                      _showMentorSelectionSheet(test, reviewModel);
                      return;
                    }
                  }

                  await context.push(
                    AppRoutes.descFullQuestions,
                    extra: DescFullQuestionsScreenArgs(
                      testId: test.id,
                      testName: test.name,
                      courseId: widget.courseModel.id,
                      isSubmitted: true,
                    ),
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

                if (!mounted) return;
                context.read<FetchCourseDetailsBloc>().add(
                  FetchCourseTestsAndResults(widget.courseModel.id),
                );
              }
              : null,
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
        statusWidget: statusWidget,
        isLocked: !isAccessible,
        price:
            (!isAccessible && !isCourseFree) ? test.singleProduct?.price : null,
        onBuyTap: () {
          _handleTestPurchase(
            context,
            testId: test.id,
            singleProduct: test.singleProduct,
            dualProduct: test.dualProduct,
            isDescriptive: true,
          );
        },
      ),
    );
  }

  void _showMentorSelectionSheet(
    DescTestModel test,
    MainsTestReviewModel reviewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Mentor Review",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              8.hGap,
              Text(
                "This test has been reviewed by multiple mentors. Select whose review you'd like to see.",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              20.hGap,
              ...reviewModel.mentorReviews.map(
                (m) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: ListTile(
                    onTap: () {
                      if (m.status.toLowerCase() != "completed") {
                        _showOverlaySnackBar(
                          context,
                          "This mentor review is still under process.",
                        );
                        return;
                      }
                      context.pop();
                      context.push(
                        AppRoutes.studentEvaluationResult,
                        extra: StudentEvaluationResultScreenArgs(
                          testId: test.id,
                          testName: test.name,
                          studentName:
                              getIt<CacheManager>().user?.name ?? 'Student',
                          reviewModel: reviewModel,
                          mentorId: m.mentorId,
                          courseId: widget.courseModel.id,
                        ),
                      );
                    },
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withAlpha(20),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    title: Text(
                      m.mentorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    subtitle: Text(
                      "Status: ${m.status}",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasNoTests() {
    final t = widget.courseModel.tests;
    if (t == null) return true;
    return (t.prelims == null || t.prelims!.isEmpty) &&
        (t.descriptive == null || t.descriptive!.isEmpty);
  }

  Future<void> _navigateToInstruction(TestModel test) async {
    await context.push(
      AppRoutes.prelimsInstructionsScreen,
      extra: PrelimsInstructionScreenArgs(testId: test.id),
    );
  }

  Widget _bottomBar(bool isEnrolled, {bool isLoading = false}) {
    final bool isFree =
        widget.courseModel.singleProduct.productId == ProductIds.freeCourse;
    final bool hasPrice = widget.courseModel.singleProduct.price > 0 || isFree;
    final bool isPrelims =
        widget.courseModel.testType == CourseTestType.prelims;
    final bool showPrice = !isEnrolled && isPrelims && hasPrice;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
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
                        isFree
                            ? "Free Access"
                            : "₹${widget.courseModel.singleProduct.price}",
                        style: TextStyle(
                          fontSize: isFree ? 18.sp : 22.sp,
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
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: const Color(0xFF10B981),
                          size: 20.sp,
                        ),
                        10.wGap,
                        Text(
                          "Enrolled Successfully",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : (showPrice
                    ? ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _handleEnrollment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child:
                          isLoading
                              ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                "Enroll Now",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    )
                    : Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : () => _handleEnrollment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child:
                            isLoading
                                ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  isFree ? "Enroll for Free" : "Enroll Now",
                                  style: TextStyle(
                                    fontSize: 15.sp,
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
    AssessmentType? selectedType;
    if (widget.courseModel.testType == CourseTestType.mains) {
      selectedType = await context.push<AssessmentType>(
        AppRoutes.assessmentTypeSelection,
        extra: AssessmentTypeSelectionScreenArgs(
          courseModel: widget.courseModel,
        ),
      );
    } else {
      selectedType = AssessmentType.single;
    }

    if (selectedType == null) return;
    if (!mounted) return;

    final payload = UserPurchasePayload(
      userId: getIt<CacheManager>().user?.id ?? 0,
      courseId: widget.courseModel.id,
      testIds: [0],
      productId: '',
      // Placeholder, populated in PurchaseBloc after native purchase
      purchaseToken:
          '', // Placeholder, populated in PurchaseBloc after native purchase
    );

    // Select the product ID from the course model based on the assessment type.
    final String? productId =
        (selectedType == AssessmentType.double)
            ? widget.courseModel.dualProduct?.productId
            : widget.courseModel.singleProduct.productId;

    payload.productId = productId ?? '';
    payload.assessmentType = selectedType;

    if (productId == ProductIds.freeCourse) {
      context.read<PurchaseBloc>().add(PurchaseCourse(payload));
      return;
    }

    if (productId != null && productId.isNotEmpty) {
      context.read<PurchaseBloc>().add(
        InitiateIapPurchase(productId: productId, backendPayload: payload),
      );
    }
  }

  /// Handles purchasing an individual test (prelims or descriptive).
  Future<void> _handleTestPurchase(
    BuildContext context, {
    required int testId,
    required ProductModel? singleProduct,
    required ProductModel? dualProduct,
    required bool isDescriptive,
  }) async {
    AssessmentType? selectedType;

    if (isDescriptive) {
      selectedType = await context.push<AssessmentType>(
        AppRoutes.assessmentTypeSelection,
        extra: AssessmentTypeSelectionScreenArgs(
          courseModel: widget.courseModel,
          testSingleProduct: singleProduct,
          testDualProduct: dualProduct,
        ),
      );
      if (selectedType == null) return;
    } else {
      selectedType = AssessmentType.single;
    }

    final String? productId =
        (selectedType == AssessmentType.double)
            ? dualProduct?.productId
            : singleProduct?.productId;

    final payload = UserPurchasePayload(
      userId: getIt<CacheManager>().user?.id ?? 0,
      courseId: widget.courseModel.id,
      testIds: [testId],
      productId: productId ?? '',
      purchaseToken: '',
      assessmentType: selectedType,
    );

    if (productId == ProductIds.freeCourse) {
      context.read<PurchaseBloc>().add(PurchaseCourse(payload));
      return;
    }

    if (productId != null && productId.isNotEmpty) {
      context.read<PurchaseBloc>().add(
        InitiateIapPurchase(productId: productId, backendPayload: payload),
      );
    }
  }

  Widget _buildTestItem({
    required TestModel test,
    required String index,
    required bool isAccessible,
  }) {
    final bool isCourseFree =
        widget.courseModel.singleProduct.productId == ProductIds.freeCourse;
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
    debugPrint('=== TEST: ${test.name}');
    debugPrint('isAccessible: $isAccessible');
    debugPrint('singleProduct: ${test.singleProduct}');
    debugPrint('price: ${test.singleProduct?.price}');
    Widget? statusWidget;
    if (isAccessible) {
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
    }

    return InkWell(
      onTap:
          isAccessible
              ? () async {
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
              }
              : null,
      borderRadius: BorderRadius.circular(12.r),
      child: _testItemContainer(
        index: index,
        name: test.name,
        details: details,
        badgeLabel: badgeLabel,
        badgeColor: badgeColor,
        statusWidget: statusWidget,
        isLocked: !isAccessible,
        price: !isAccessible ? test.singleProduct?.price : null,
        onBuyTap: () {
          _handleTestPurchase(
            context,
            testId: test.id,
            singleProduct: test.singleProduct,
            dualProduct: test.dualProduct,
            isDescriptive: false,
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          6.wGap,
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
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

  Widget _testItemContainer({
    required String index,
    required String name,
    required String details,
    required String badgeLabel,
    required Color badgeColor,
    Widget? statusWidget,
    bool isLocked = false,
    int? price,
    VoidCallback? onBuyTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                6.hGap,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    8.wGap,
                    Flexible(
                      child: Text(
                        details,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (statusWidget != null) statusWidget,
              ],
            ),
          ),
          12.wGap,
          isLocked
              ? (price != null && price > 0
                  ? InkWell(
                    onTap: onBuyTap,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Buy ₹$price',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  : Icon(
                    Icons.lock_person_rounded,
                    color: AppColors.gray400,
                    size: 22.sp,
                  ))
              : Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.gray400,
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

  void _showOverlaySnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50.h,
            left: 16.w,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 18.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
