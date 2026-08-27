import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/core/helpers/share_helper.dart';

import '../../../blocs/add_course/course_bloc.dart';

class AdminCourseListScreen extends StatefulWidget {
  const AdminCourseListScreen({super.key});

  @override
  State<AdminCourseListScreen> createState() => _AdminCourseListScreenState();
}

class _AdminCourseListScreenState extends State<AdminCourseListScreen> {
  List<CourseModel> _allCourses = [];
  List<CourseModel> _filteredCourses = [];
  String _searchQuery = "";
  String _selectedFilter = "All"; // "All", "Active", "Inactive"
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    context.read<CourseBloc>().add(FetchCoursesRequested(isAdmin: true));
  }

  void _applyFilters() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        final matchesSearch =
            course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        bool matchesStatus = true;
        if (_selectedFilter == "Active") {
          matchesStatus = course.isActive == true;
        } else if (_selectedFilter == "Inactive") {
          matchesStatus = course.isActive == false;
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
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
          'Course List (Admin)',
          style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
        ),
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<CourseBloc, CourseState>(
        listener: (context, state) {
          if (state is FetchCoursesSuccess) {
            _allCourses = state.courses;
            _applyFilters();
          }
        },
        builder: (context, state) {
          final isLoading = state is CourseLoading;

          if (isLoading && _allCourses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FetchCoursesFailure && _allCourses.isEmpty) {
            return Center(child: Text(state.error));
          }

          final int totalCount = _allCourses.length;
          final int activeCount = _allCourses
              .where((c) => c.isActive == true)
              .length;
          final int inactiveCount = totalCount - activeCount;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await _loadCourses();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats summary cards
                _buildStatsSummary(totalCount, activeCount, inactiveCount),

                // Search Bar
                _buildSearchBar(),

                // Filter Chips
                _buildFilterChips(),

                12.hGap,

                // Course list
                Expanded(
                  child: _filteredCourses.isEmpty
                      ? const Center(
                          child: Text('No courses found matching criteria'),
                        )
                      : NotificationListener<ScrollStartNotification>(
                          onNotification: (notification) {
                            _searchFocusNode.unfocus();
                            return false;
                          },
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            itemCount: _filteredCourses.length,
                            separatorBuilder: (context, index) => 12.hGap,
                            itemBuilder: (context, index) {
                              final course = _filteredCourses[index];
                              return _buildCourseCard(course);
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSummary(int total, int active, int inactive) {
    return Container(
      height: 85.h,
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            title: 'Total Courses',
            value: '$total',
            icon: Icons.library_books_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          12.wGap,
          _buildStatCard(
            title: 'Active',
            value: '$active',
            icon: Icons.check_circle_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          12.wGap,
          _buildStatCard(
            title: 'Inactive',
            value: '$inactive',
            icon: Icons.offline_pin_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      width: 140.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: Colors.white.withAlpha(220), size: 16.sp),
            ],
          ),
          6.hGap,
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: 12.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          focusNode: _searchFocusNode,
          onChanged: (value) {
            _searchQuery = value;
            _applyFilters();
          },
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: AppTexts.subTitle.copyWith(color: AppColors.gray400),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.gray500,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: ["All", "Active", "Inactive"].map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.gray700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    _applyFilters();
                  });
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.gray200,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              pressElevation: 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final isCourseActive = course.isActive;
    final typeLabel = course.testType?.name.toUpperCase() ?? "COURSE";

    return ElevatedContainer(
      borderRadius: 20.r,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () async {
          await context.push(
            AppRoutes.adminCourseDetails,
            extra: AdminCourseDetailsScreenArgs(courseModel: course),
          );
          _loadCourses();
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Test type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Status badge and Share button
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isCourseActive
                              ? AppColors.green100
                              : AppColors.red100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isCourseActive ? "ACTIVE" : "INACTIVE",
                          style: TextStyle(
                            color: isCourseActive
                                ? AppColors.green800
                                : AppColors.red800,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      8.wGap,
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.share_outlined,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        onPressed: () => ShareHelper.shareCourse(course),
                      ),
                    ],
                  ),
                ],
              ),
              12.hGap,
              Text(
                course.name,
                style: AppTexts.heading.copyWith(
                  color: AppColors.gray900,
                  fontSize: 16.sp,
                ),
              ),
              12.hGap,
              Divider(height: 1, color: AppColors.gray100),
              12.hGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        color: AppColors.gray400,
                        size: 14.sp,
                      ),
                      4.wGap,
                      Text(
                        '${(course.tests?.prelims?.length ?? 0) + (course.tests?.descriptive?.length ?? 0)} Tests',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.wGap,
                      Icon(
                        Icons.people_outline,
                        color: AppColors.gray400,
                        size: 14.sp,
                      ),
                      4.wGap,
                      Text(
                        '${course.fullCoursePurchaseCount ?? 0} Students',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
