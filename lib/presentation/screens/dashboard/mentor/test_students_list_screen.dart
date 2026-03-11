import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_test_submissions.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/test_students_list/test_students_list_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestStudentsListScreen extends StatefulWidget {
  final int testId;
  final String testName;

  const TestStudentsListScreen({
    super.key,
    required this.testId,
    required this.testName,
  });

  @override
  State<TestStudentsListScreen> createState() => _TestStudentsListScreenState();
}

class _TestStudentsListScreenState extends State<TestStudentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TestStudentsListBloc>().add(
      FetchTestStudentsList(widget.testId),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.testName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            BlocBuilder<TestStudentsListBloc, TestStudentsListState>(
              builder: (context, state) {
                if (state is TestStudentsListLoaded) {
                  return Text(
                    '${state.submissions.length} Students Enrolled',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<TestStudentsListBloc, TestStudentsListState>(
        builder: (context, state) {
          if (state is TestStudentsListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TestStudentsListError) {
            return Center(child: Text(state.message));
          }

          if (state is TestStudentsListLoaded) {
            return Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentList(state.submissions, 'All'),
                      _buildStudentList(state.submissions, 'Pending'),
                      _buildStudentList(state.submissions, 'Submitted'),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        border: Border(bottom: BorderSide(color: AppColors.gray100, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray500,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Submitted'),
        ],
      ),
    );
  }

  Widget _buildStudentList(
    List<MentorTestSubmissions> submissions,
    String statusFilter,
  ) {
    final filteredSubmissions =
        statusFilter == 'All'
            ? submissions
            : statusFilter == 'Pending'
            ? submissions.where((s) => !s.isChecked).toList()
            : submissions.where((s) => s.isChecked).toList();

    if (filteredSubmissions.isEmpty) {
      return Center(
        child: Text(
          'No ${statusFilter.toLowerCase()} students found',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: filteredSubmissions.length,
      separatorBuilder: (context, index) => 16.hGap,
      itemBuilder: (context, index) {
        final submission = filteredSubmissions[index];
        return _buildStudentCard(submission);
      },
    );
  }

  Widget _buildStudentCard(MentorTestSubmissions submission) {
    return GestureDetector(
      onTap: () {
        if (submission.isChecked == false) {
          context.push(
            AppRoutes.mentorEvaluation,
            extra: MentorEvaluationScreenArgs(
              mentorAssignmentId: submission.mentorAssignmentId,
              submissionId: submission.submissionId,
              studentId: submission.studentId,
              testId: widget.testId,
              studentName: submission.studentName,
              testName: widget.testName,
              isChecked: submission.isChecked,
            ),
          );
        }
      },
      child: Container(
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.gray100,
              child: Icon(Icons.person_rounded, color: AppColors.gray400),
            ),
            16.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.studentName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  4.hGap,
                  Text(
                    submission.isChecked
                        ? 'Checked on ${submission.submittedAt.toFormattedDate()}'
                        : 'Submitted on ${submission.submittedAt.toFormattedDate()}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(submission.isChecked ? 'Submitted' : 'Pending'),
            12.wGap,
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gray400,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color =
        status == 'Pending' ? AppColors.orange500 : AppColors.primary;
    final Color bgColor = color.withAlpha(15);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
