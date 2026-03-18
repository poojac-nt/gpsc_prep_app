import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_free_test_list_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/free_test_review/free_test_review_state.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class FreeTestReviewScreen extends StatelessWidget {
  const FreeTestReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => FreeTestReviewBloc(getIt())..add(FetchFreeTestReviews()),
      child: const FreeTestReviewView(),
    );
  }
}

class FreeTestReviewView extends StatefulWidget {
  const FreeTestReviewView({super.key});

  @override
  State<FreeTestReviewView> createState() => _FreeTestReviewViewState();
}

class _FreeTestReviewViewState extends State<FreeTestReviewView> {
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
      getIt<LogHelper>().e("Error parsing createdAt: $e");
      getIt<SnackBarHelper>().showError("Error parsing createdAt: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text('Free Test Submissions', style: AppTexts.titleTextStyle),
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.gray900),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<FreeTestReviewBloc, FreeTestReviewState>(
        builder: (context, state) {
          if (state is FreeTestReviewLoading ||
              state is FreeTestReviewInitial) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is FreeTestReviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  16.hGap,
                  ElevatedButton(
                    onPressed:
                        () => context.read<FreeTestReviewBloc>().add(
                          FetchFreeTestReviews(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FreeTestReviewLoaded) {
            if (state.submissions.isEmpty) {
              return Center(
                child: Text(
                  'No free test submissions found.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
              );
            }

            // Flatten the list to get all submissions as separate items
            final List<Map<String, dynamic>> flatSubmissions = [];
            for (var testGroup in state.submissions) {
              for (var user in testGroup.users) {
                flatSubmissions.add({'test': testGroup, 'user': user});
              }
            }

            if (flatSubmissions.isEmpty) {
              return Center(
                child: Text(
                  'No user submissions found for free tests.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<FreeTestReviewBloc>().add(FetchFreeTestReviews());
              },
              child: ListView.separated(
                padding: EdgeInsets.all(20.w),
                itemCount: flatSubmissions.length,
                separatorBuilder: (context, index) => 16.hGap,
                itemBuilder: (context, index) {
                  final item = flatSubmissions[index];
                  final DescFreeTestWithUsers testGroup = item['test'];
                  final SubmittedUser user = item['user'];

                  final isUnlocked = isAnswerUnlocked(
                    testGroup.createdAt.toIso8601String(),
                  );

                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primary.withAlpha(20),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            12.wGap,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.userName,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  4.hGap,
                                  Text(
                                    testGroup.name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.gray500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        16.hGap,
                        const Divider(color: AppColors.gray100, height: 1),
                        12.hGap,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.format_list_numbered,
                                  size: 14.sp,
                                  color: AppColors.gray400,
                                ),
                                4.wGap,
                                Text(
                                  '${testGroup.noQuestions} Questions',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.gray500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.grade_rounded,
                                  size: 14.sp,
                                  color: AppColors.gray400,
                                ),
                                4.wGap,
                                Text(
                                  '${testGroup.totalMarks} Marks',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.gray500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        16.hGap,
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    side: BorderSide(
                                      color: AppColors.primary,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  final testModel = DescTestModel(
                                    id: testGroup.testId,
                                    name: testGroup.name,
                                    totalMarks: testGroup.totalMarks,
                                    noQuestions: testGroup.noQuestions,
                                    createdAt:
                                        testGroup.createdAt.toIso8601String(),
                                  );
                                  context.push(
                                    AppRoutes.descAnswerScreen,
                                    extra: {
                                      'descTestModel': testModel,
                                      'isUnlocked': isUnlocked,
                                      'showPeerReview': true,
                                      'peerUserId':
                                          user.userId, // Passing student ID if backend uses it
                                    },
                                  );
                                },
                                child: Text(
                                  'Review',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            12.wGap,
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                onPressed:
                                    isUnlocked
                                        ? () {
                                          final testModel = DescTestModel(
                                            id: testGroup.testId,
                                            name: testGroup.name,
                                            totalMarks: testGroup.totalMarks,
                                            noQuestions: testGroup.noQuestions,
                                            createdAt:
                                                testGroup.createdAt
                                                    .toIso8601String(),
                                          );
                                          context.push(
                                            AppRoutes.descAnswerScreen,
                                            extra: {
                                              'descTestModel': testModel,
                                              'isUnlocked': isUnlocked,
                                              'showPeerReview': false,
                                            },
                                          );
                                        }
                                        : null,
                                child: Text(
                                  'Answer Key',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
}
