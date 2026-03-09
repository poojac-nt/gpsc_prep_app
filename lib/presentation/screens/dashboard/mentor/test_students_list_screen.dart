import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestStudentsListScreen extends StatefulWidget {
  const TestStudentsListScreen({super.key});

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
              'Prelims Full Test - 05',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            Text(
              '42 Students Enrolled',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentList('All'),
                _buildStudentList('Pending'),
                _buildStudentList('Submitted'),
              ],
            ),
          ),
        ],
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

  Widget _buildStudentList(String statusFilter) {
    final List<Map<String, dynamic>> allStudents = [
      {
        'name': 'Priya Sharma',
        'subInfo': 'Submitted on 13 Oct 2023',
        'status': 'Submitted',
      },
      {
        'name': 'Rahul Verma',
        'subInfo': 'Due by 15 Oct 2023',
        'status': 'Pending',
      },
      {
        'name': 'Siddharth Nair',
        'subInfo': 'Due by 15 Oct 2023',
        'status': 'Pending',
      },
      {
        'name': 'Megha Iyer',
        'subInfo': 'Submitted on 14 Oct 2023',
        'status': 'Submitted',
      },
    ];

    final filteredStudents =
        statusFilter == 'All'
            ? allStudents
            : allStudents.where((s) => s['status'] == statusFilter).toList();

    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: filteredStudents.length,
      separatorBuilder: (context, index) => 16.hGap,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.mentorEvaluation),
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
                    student['name'],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  4.hGap,
                  Text(
                    student['subInfo'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(student['status']),
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
