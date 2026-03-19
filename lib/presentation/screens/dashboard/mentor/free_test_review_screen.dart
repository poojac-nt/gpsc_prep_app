import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_state.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';

class FreeTestReviewScreen extends StatefulWidget {
  const FreeTestReviewScreen({super.key});

  @override
  State<FreeTestReviewScreen> createState() => _FreeTestReviewScreenState();
}

class _FreeTestReviewScreenState extends State<FreeTestReviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FreeTestReviewBloc>().add(FetchFreeTestReviews());
  }

  bool isAnswerUnlocked(String createdAtString) {
    try {
      final createdAtUtc = DateTime.parse(createdAtString).toUtc();
      final unlockTimeUtc = DateTime.utc(
        createdAtUtc.year,
        createdAtUtc.month,
        createdAtUtc.day,
        11,
        30,
      );

      final nowUtc = DateTime.now().toUtc();
      return nowUtc.isAfter(unlockTimeUtc);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Free Test Reviews', style: AppTexts.titleTextStyle),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.gray900,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<FreeTestReviewBloc, FreeTestReviewState>(
        builder: (context, state) {
          if (state is FreeTestReviewLoading ||
              state is FreeTestReviewInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          if (state is FreeTestReviewError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade300,
                      size: 48.sp,
                    ),
                    16.hGap,
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.gray700,
                        fontSize: 14.sp,
                      ),
                    ),
                    24.hGap,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                      ),
                      onPressed:
                          () => context.read<FreeTestReviewBloc>().add(
                            FetchFreeTestReviews(),
                          ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is FreeTestReviewLoaded) {
            final submissions = state.submissions;
            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      color: AppColors.gray200,
                      size: 64.sp,
                    ),
                    16.hGap,
                    Text(
                      'No submissions for review',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<FreeTestReviewBloc>().add(FetchFreeTestReviews());
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: submissions.length,
                separatorBuilder: (context, index) => 16.hGap,
                itemBuilder: (context, index) {
                  final test = submissions[index];
                  final isUnlocked = isAnswerUnlocked(test.createdAt);
                  final formattedDate = DateFormat(
                    'dd MMM, yyyy',
                  ).format(DateTime.parse(test.createdAt));

                  return Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(8),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                                size: 22.sp,
                              ),
                            ),
                            16.wGap,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    test.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  4.hGap,
                                  Text(
                                    'Published on $formattedDate',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.gray500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        16.hGap,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildInfoChip(
                              Icons.quiz_outlined,
                              '${test.noQuestions} Questions',
                              const Color(0xFFF1F5F9),
                              const Color(0xFF475569),
                            ),
                            12.wGap,
                            _buildInfoChip(
                              Icons.stars_outlined,
                              '${test.totalMarks} Marks',
                              const Color(0xFFF0FDF4),
                              const Color(0xFF166534),
                            ),
                          ],
                        ),
                        20.hGap,
                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        15.hGap,
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionBtn(
                                label: 'Answer Key',
                                isPrimary: true,
                                isDisabled: !isUnlocked,
                                onTap: () {
                                  context.push(
                                    AppRoutes.descAnswerScreen,
                                    extra: {
                                      'descTestModel': test,
                                      'isUnlocked': isUnlocked,
                                      'showPeerReview': false,
                                    },
                                  );
                                },
                              ),
                            ),
                            12.wGap,
                            Expanded(
                              child: _buildActionBtn(
                                label: 'Review',
                                isPrimary: false,
                                onTap: () {
                                  context.push(
                                    AppRoutes.descAnswerScreen,
                                    extra: {
                                      'descTestModel': test,
                                      'isUnlocked': isUnlocked,
                                      'showPeerReview': true,
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          6.wGap,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required bool isPrimary,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color:
              isDisabled
                  ? AppColors.gray100
                  : (isPrimary ? AppColors.primary : Colors.white),
          borderRadius: BorderRadius.circular(14.r),
          border:
              isPrimary || isDisabled
                  ? null
                  : Border.all(
                    color: AppColors.primary.withAlpha(100),
                    width: 1.5,
                  ),
          boxShadow:
              isPrimary && !isDisabled
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color:
                  isDisabled
                      ? AppColors.gray400
                      : (isPrimary ? Colors.white : AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}
