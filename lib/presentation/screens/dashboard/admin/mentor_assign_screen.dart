import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorAssignScreen extends StatefulWidget {
  const MentorAssignScreen({super.key});

  @override
  State<MentorAssignScreen> createState() => _MentorAssignScreenState();
}

class _MentorAssignScreenState extends State<MentorAssignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Individual selection state maps: { studentIndex: [mentorIndices] }
  final Map<int, List<int>> _singleSelections = {};
  final Map<int, List<int>> _doubleSelections = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(child: _buildTabBar()),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList(isDoubleReview: false),
            _buildTaskList(isDoubleReview: true),
          ],
        ),
      ),
      bottomNavigationBar: _buildChangesPendingBanner(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Mentor Allocation ",
        style: TextStyle(
          color: AppColors.gray900,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.gray900,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Task Queue",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              letterSpacing: -1,
            ),
          ),
          4.hGap,
          Text(
            "Candidates awaiting verification",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: "Unassigned",
              value: "48",
              icon: Icons.auto_awesome_mosaic_rounded,
              color: AppColors.primary,
            ),
          ),
          16.wGap,
          Expanded(
            child: _buildStatCard(
              label: "Total Courses",
              value: "100",
              icon: Icons.join_inner_rounded,
              color: AppColors.orange500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      color: AppColors.scaffoldColor,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray500,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [Tab(text: "Single"), Tab(text: "Double")],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),
            ],
          ),
          16.hGap,
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList({required bool isDoubleReview}) {
    return ListView.builder(
      key: PageStorageKey(isDoubleReview ? 'double' : 'single'),
      padding: EdgeInsets.fromLTRB(
        24.w,
        8.h,
        24.w,
        8.h,
      ), // Minimized bottom padding
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildStudentTaskCard(
          index: index,
          isDoubleReview: isDoubleReview,
          name: index % 2 == 0 ? "Aman Gupta" : "Priya Sharma",
        );
      },
    );
  }

  Widget _buildStudentTaskCard({
    required int index,
    required bool isDoubleReview,
    required String name,
  }) {
    final selections = isDoubleReview ? _doubleSelections : _singleSelections;
    final selectedIndices = selections[index] ?? [];

    String mentorName = "Select Evaluator";
    if (selectedIndices.isNotEmpty) {
      if (isDoubleReview) {
        mentorName = "${selectedIndices.length} Evaluators Selected";
      } else {
        // Mock names for display
        final names = [
          "Dr. Sarah Wilson",
          "Michael Page",
          "Prof. James Miller",
          "Anjali Sharma",
        ];
        mentorName = names[selectedIndices.first];
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 20.h, top: 2.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              16.wGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "GPSC Mains - Essay Paper,GPSC Mains - Essay Paper",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          24.hGap,
          _buildMentorSelector(
            label: isDoubleReview ? "Assign Evaluators" : "Assign Mentor",
            name: mentorName,
            isPlaceholder: selectedIndices.isEmpty,
            onTap: () => _showMentorSelectionSheet(index, isDoubleReview),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorSelector({
    required String label,
    required String name,
    bool isPlaceholder = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.gray500.withAlpha(150),
            letterSpacing: 1,
          ),
        ),
        8.hGap,
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.scaffoldColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.gray200),
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
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              isPlaceholder
                                  ? AppColors.gray400
                                  : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isPlaceholder ? Icons.add_rounded : Icons.swap_vert_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMentorSelectionSheet(int studentIndex, bool isDoubleReview) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selections =
                isDoubleReview ? _doubleSelections : _singleSelections;
            final selectedIndices = selections[studentIndex] ?? [];

            return Container(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  24.hGap,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isDoubleReview ? "Select Mentors" : "Select Mentor",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  16.hGap,
                  _buildMentorItem(
                    "Dr. Sarah Wilson",
                    0,
                    studentIndex,
                    isDoubleReview,
                    setSheetState,
                  ),
                  _buildMentorItem(
                    "Michael Page",
                    1,
                    studentIndex,
                    isDoubleReview,
                    setSheetState,
                  ),
                  _buildMentorItem(
                    "Prof. James Miller",
                    2,
                    studentIndex,
                    isDoubleReview,
                    setSheetState,
                  ),
                  _buildMentorItem(
                    "Anjali Sharma",
                    3,
                    studentIndex,
                    isDoubleReview,
                    setSheetState,
                  ),
                  if (isDoubleReview) ...[
                    24.hGap,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {}); // Update the main UI
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          "Confirm Selection",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMentorItem(
    String name,
    int mentorIndex,
    int studentIndex,
    bool isDoubleReview,
    StateSetter setSheetState,
  ) {
    final selections = isDoubleReview ? _doubleSelections : _singleSelections;
    if (!selections.containsKey(studentIndex)) {
      selections[studentIndex] = [];
    }
    final selectedIndices = selections[studentIndex]!;
    final bool isSelected = selectedIndices.contains(mentorIndex);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary.withAlpha(25),
          child: Text(
            name[0],
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        trailing:
            isDoubleReview
                ? Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  onChanged: (value) {
                    setSheetState(() {
                      if (value == true) {
                        selectedIndices.add(mentorIndex);
                      } else {
                        selectedIndices.remove(mentorIndex);
                      }
                    });
                  },
                )
                : (isSelected
                    ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null),
        onTap: () {
          setSheetState(() {
            if (isDoubleReview) {
              if (isSelected) {
                selectedIndices.remove(mentorIndex);
              } else {
                selectedIndices.add(mentorIndex);
              }
            } else {
              selectedIndices.clear();
              selectedIndices.add(mentorIndex);
            }
          });
          if (!isDoubleReview) {
            setState(() {}); // Update main UI
            Future.delayed(const Duration(milliseconds: 200), () {
              Navigator.pop(context);
            });
          }
        },
      ),
    );
  }

  Widget _buildChangesPendingBanner() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assignments",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  "PENDING SYNC",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              "SYNC ALL",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 60.h;
  @override
  double get maxExtent => 60.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
