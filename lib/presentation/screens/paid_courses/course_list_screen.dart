import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/router/args.dart';
import '../../blocs/add_course/course_bloc.dart';
import '../../blocs/purchase/purchase_bloc.dart';
import 'package:gpsc_prep_app/core/helpers/share_helper.dart';

class PaidCourseListScreen extends StatefulWidget {
  const PaidCourseListScreen({super.key});

  @override
  State<PaidCourseListScreen> createState() => _PaidCourseListScreenState();
}

class _PaidCourseListScreenState extends State<PaidCourseListScreen> {
  @override
  void initState() {
    context.read<CourseBloc>().add(FetchCoursesRequested());
    context.read<PurchaseBloc>().add(FetchPurchases());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text("Premium Courses", style: AppTexts.titleTextStyle),
        centerTitle: false,
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          final bool isLoading = state is CourseLoading;
          final List<CourseModel> courses =
              state is FetchCoursesSuccess ? state.courses : [];

          if (state is FetchCoursesFailure) {
            return Center(child: Text(state.error));
          }

          if (!isLoading && courses.isEmpty) {
            return const Center(child: Text("No courses found"));
          }

          return BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, purchaseState) {
              final enrolledCourseIds =
                  (purchaseState is PurchaseFetched)
                      ? purchaseState.purchases.map((p) => p.courseId).toSet()
                      : (purchaseState is PurchaseSuccess)
                      ? purchaseState.purchases.map((p) => p.courseId).toSet()
                      : <int>{};

              return Skeletonizer(
                enabled: isLoading,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  itemCount: courses.length,
                  separatorBuilder: (context, index) => 10.hGap,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return PaidCourseListCard(
                      courseModel: course,
                      isEnrolled: enrolledCourseIds.contains(course.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PaidCourseListCard extends StatelessWidget {
  final CourseModel courseModel;
  final bool isEnrolled;

  const PaidCourseListCard({
    super.key,
    required this.courseModel,
    this.isEnrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrelims = courseModel.testType == CourseTestType.prelims;

    return ElevatedContainer(
      borderRadius: 20.r,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.courseDetails,
            extra: CourseDetailsScreenArgs(courseModel: courseModel),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header pill
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPrelims
                              ? AppColors.green100.withAlpha(150)
                              : const Color(0xFFF3E8FF), // Purple 100
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Text(
                      courseModel.testType?.displayName ?? 'Prelims',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isPrelims
                                ? AppColors.green800.withAlpha(160)
                                : const Color(0xFF7E22CE), // Purple 700
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Share Course",
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    onPressed: () => _handleShare(context),
                  ),
                ],
              ),
              12.hGap,
              Text(
                courseModel.name,
                style: AppTexts.heading.copyWith(
                  height: 1.2.h,
                  color: AppColors.gray900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              12.hGap,

              Divider(color: AppColors.gray100, height: 1.h),
              16.hGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (courseModel.singleProduct.price > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Starting from",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₹${courseModel.singleProduct.price}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEnrolled ? "Enrolled" : "View Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        6.wGap,
                        Icon(
                          isEnrolled
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    await ShareHelper.shareCourse(courseModel);
  }
}
