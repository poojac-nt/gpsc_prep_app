import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/pending_submission.dart';
import 'package:gpsc_prep_app/presentation/blocs/pending_submissions/pending_submissions_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorAssignScreen extends StatefulWidget {
  const MentorAssignScreen({super.key});

  @override
  State<MentorAssignScreen> createState() => _MentorAssignScreenState();
}

class _MentorAssignScreenState extends State<MentorAssignScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PendingSubmissionsBloc>().add(FetchPendingSubmissions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<PendingSubmissionsBloc, PendingSubmissionsState>(
        builder: (context, state) {
          if (state is PendingSubmissionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PendingSubmissionsError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gray500),
                ),
              ),
            );
          } else if (state is PendingSubmissionsLoaded) {
            final submissions = state.pendingSubmissions;
            if (submissions.isEmpty) {
              return Center(
                child: Text(
                  "No pending submissions",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPendingHeader(submissions.length),
                  _buildTestList(submissions),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Tests with Submissions",
        style: TextStyle(
          color: AppColors.gray900,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.gray900,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPendingHeader(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Pending Submissions",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "$count New",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList(List<PendingSubmission> submissions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final item = submissions[index];
        return _buildTestSubmissionCard(item);
      },
    );
  }

  Widget _buildTestSubmissionCard(PendingSubmission item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
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
                  item.testName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                2.hGap,
                Text(
                  "${item.unassignedSubmissions} submissions",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context)
                  .push(
                    AppRoutes.assignMentorDetail,
                    extra: {'testId': item.testId, 'testName': item.testName},
                  )
                  .then((_) {
                    if (mounted) {
                      context.read<PendingSubmissionsBloc>().add(
                        FetchPendingSubmissions(),
                      );
                    }
                  });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: Size(80.w, 36.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              "Assign",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
