import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_assignment_list_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/mentor/all_assigned_tests_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AllAssignedTestsScreen extends StatefulWidget {
  const AllAssignedTestsScreen({super.key});

  @override
  State<AllAssignedTestsScreen> createState() => _AllAssignedTestsScreenState();
}

class _AllAssignedTestsScreenState extends State<AllAssignedTestsScreen> {
  String selectedSubject = 'All Subjects';
  List<String> availableSubjects = ['All Subjects'];

  @override
  void initState() {
    super.initState();
    context.read<AllAssignedTestsBloc>().add(FetchAllAssignedTests());
  }

  void _extractSubjects(List<MentorAssignmentListModel> data) {
    final Set<String> subjectSet = {'All Subjects'};
    for (var test in data) {
      for (var subject in test.subjects) {
        subjectSet.add(subject.subjectName);
      }
    }
    availableSubjects = subjectSet.toList();
    if (!availableSubjects.contains(selectedSubject)) {
      selectedSubject = 'All Subjects';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: BlocBuilder<AllAssignedTestsBloc, AllAssignedTestsState>(
        builder: (context, state) {
          if (state is AllAssignedTestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AllAssignedTestsError) {
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
                        () => context.read<AllAssignedTestsBloc>().add(
                          FetchAllAssignedTests(),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AllAssignedTestsLoaded) {
            _extractSubjects(state.data);

            final filteredData =
                selectedSubject == 'All Subjects'
                    ? state.data
                    : state.data
                        .where(
                          (test) => test.subjects.any(
                            (s) => s.subjectName == selectedSubject,
                          ),
                        )
                        .toList();

            return Column(
              children: [
                16.hGap,
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<AllAssignedTestsBloc>().add(
                        FetchAllAssignedTests(),
                      );
                    },
                    child: _buildTestList(filteredData),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.gray900),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'All Assigned Tests',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.gray900,
          letterSpacing: -0.5,
        ),
      ),
      actions: [_buildSubjectFilter()],
    );
  }

  Widget _buildSubjectFilter() {
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Icon(Icons.tune_rounded, color: AppColors.gray900, size: 24.sp),
      onSelected: (String value) {
        setState(() => selectedSubject = value);
      },
      itemBuilder:
          (BuildContext context) =>
              availableSubjects.map((String subject) {
                return PopupMenuItem<String>(
                  value: subject,
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          selectedSubject == subject
                              ? FontWeight.w700
                              : FontWeight.w500,
                      color:
                          selectedSubject == subject
                              ? AppColors.primary
                              : AppColors.gray900,
                    ),
                  ),
                );
              }).toList(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 4,
    );
  }

  Widget _buildTestList(List<MentorAssignmentListModel> data) {
    if (data.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Text(
              'No tests found.',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final test = data[index];
        return GestureDetector(
          onTap:
              () => context.push(
                AppRoutes.testStudentsList,
                extra: {'testId': test.testId, 'testName': test.testName},
              ),
          child: _buildTestCard(test),
        );
      },
    );
  }

  Widget _buildTestCard(MentorAssignmentListModel test) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.testName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    8.hGap,
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          color: AppColors.gray400,
                          size: 14.sp,
                        ),
                        6.wGap,
                        Text(
                          '${test.totalAssignedForTest} Students',
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
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.gray400,
                size: 16.sp,
              ),
            ],
          ),
          12.hGap,
          const Divider(height: 1, color: AppColors.gray100),
          12.hGap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.book_rounded,
                      color: AppColors.gray400,
                      size: 14.sp,
                    ),
                    6.wGap,
                    Expanded(
                      child: Text(
                        test.subjects.map((s) => s.subjectName).join(', '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (test.allCompleted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
