import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/selection_drawer.dart';
import 'package:gpsc_prep_app/presentation/widgets/mentor_assignment_tile.dart';
import 'package:gpsc_prep_app/presentation/widgets/mentor_progress_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/mentor_stat_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      drawer: SelectionDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: const Color(0xFF4F46E5),
                  size: 28.sp,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: Text(
          'Dashboard',
          style: AppTexts.titleTextStyle.copyWith(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: const Color(0xFF64748B),
              size: 24.sp,
            ),
            onPressed: () {},
          ),
          12.wGap,
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Mentor',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Here is your evaluation progress for today.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Stat Cards Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: MentorStatCard(
                      icon: Icons.description_outlined,
                      title: 'Assigned Papers',
                      value: '45',
                      trendText: '+5% vs last week',
                      iconColor: const Color(0xFF4F46E5),
                      iconBackgroundColor: const Color(0xFFEEF2FF),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: MentorStatCard(
                      icon: Icons.assignment_late_outlined,
                      title: 'Pending',
                      value: '12',
                      trendText: '+2% daily increase',
                      trendColor: const Color(0xFFF59E0B),
                      iconColor: const Color(0xFFF59E0B),
                      iconBackgroundColor: const Color(0xFFFFF7ED),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Progress Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const MentorProgressCard(
                title: 'Completed Reviews',
                value: '33',
                progress: 0.73,
                footerText: '73% of weekly goal achieved',
              ),
            ),

            SizedBox(height: 32.h),

            // Subject Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF4F46E5),
              unselectedLabelColor: const Color(0xFF94A3B8),
              indicatorColor: const Color(0xFF4F46E5),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'History'),
                Tab(text: 'Geography'),
                Tab(text: 'Polity'),
                Tab(text: 'Ethics'),
              ],
            ),

            SizedBox(height: 24.h),

            // Assignments Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Assignments',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  MentorAssignmentTile(
                    studentName: 'John Doe',
                    testTitle: 'Modern India Mock #4',
                    status: 'Pending',
                    date: 'Oct 24, 2023',
                    actionText: 'Start Checking',
                    onActionTap: () {},
                  ),
                  MentorAssignmentTile(
                    studentName: 'Amara Singh',
                    testTitle: 'Ancient History Quiz',
                    status: 'In Progress',
                    date: 'Oct 25, 2023',
                    actionText: 'Resume',
                    onActionTap: () {},
                  ),
                  MentorAssignmentTile(
                    studentName: 'Mark Knight',
                    testTitle: 'World War II Essay',
                    status: 'Evaluated',
                    date: 'Oct 22, 2023',
                    actionText: 'View Results',
                    onActionTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
