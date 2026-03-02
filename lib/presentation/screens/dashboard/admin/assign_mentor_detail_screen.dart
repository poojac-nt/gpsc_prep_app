import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AssignMentorDetailScreen extends StatefulWidget {
  final String testName;

  const AssignMentorDetailScreen({super.key, required this.testName});

  @override
  State<AssignMentorDetailScreen> createState() =>
      _AssignMentorDetailScreenState();
}

class _AssignMentorDetailScreenState extends State<AssignMentorDetailScreen> {
  final Set<int> _selectedIndices = {};

  final List<Map<String, dynamic>> dummySubmissions = [
    {
      "name": "Alice Johnson",
      "type": "Dual Assessment",
      "progress": "1/2 Complete",
      "isDual": true,
    },
    {
      "name": "Bob Smith",
      "type": "Single Assessment",
      "progress": "",
      "isDual": false,
    },
    {
      "name": "Clara Davis",
      "type": "Dual Assessment",
      "progress": "1/2 Complete",
      "isDual": true,
    },
    {
      "name": "David Miller",
      "type": "Single Assessment",
      "progress": "",
      "isDual": false,
    },
    {
      "name": "Elena Rodriguez",
      "type": "Single Assessment",
      "progress": "",
      "isDual": false,
    },
    {
      "name": "Frank White",
      "type": "Single Assessment",
      "progress": "",
      "isDual": false,
    },
  ];

  final List<Map<String, dynamic>> dummyMentors = [
    {"name": "Dr. Sarah Wilson", "subject": "Science"},
    {"name": "Michael Page", "subject": "Mathematics"},
    {"name": "Prof. James Miller", "subject": "Humanities"},
    {"name": "Anjali Sharma", "subject": "CS"},
    {"name": "Dr. Robert Fox", "subject": "Science"},
    {"name": "Emily Chen", "subject": "English"},
  ];

  String _getSubjectFromTestName(String testName) {
    if (testName.contains("Physics") || testName.contains("Science")) {
      return "Science";
    }
    if (testName.contains("Calculus") || testName.contains("Math")) {
      return "Mathematics";
    }
    if (testName.contains("History") || testName.contains("Humanities")) {
      return "Humanities";
    }
    if (testName.contains("Data Structures") || testName.contains("CS")) {
      return "CS";
    }
    if (testName.contains("Literature") || testName.contains("English")) {
      return "English";
    }
    return "All";
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [10.hGap, _buildSubmissionList()],
            ),
          ),
          _buildFloatingButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.gray900,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            widget.testName,
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "ASSIGN MENTORS",
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: dummySubmissions.length,
      itemBuilder: (context, index) {
        final submission = dummySubmissions[index];
        return _buildSubmissionCard(submission, index);
      },
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission, int index) {
    final bool isSelected = _selectedIndices.contains(index);
    return GestureDetector(
      onTap: () => _toggleSelection(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
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
            _buildCustomCheckbox(isSelected),
            12.wGap,
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.primary.withAlpha(15),
              child: Text(
                submission["name"]![0],
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            16.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        submission["name"]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  4.hGap,
                  Text(
                    submission["type"]!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (submission["progress"].isNotEmpty) ...[
              8.wGap,
              _buildProgressIndicator(submission["progress"]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String progress) {
    // Assuming simple format like "1/2 Complete"
    bool isHalf = progress.contains("1/2");
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_buildSegment(true), 4.wGap, _buildSegment(!isHalf)],
    );
  }

  Widget _buildSegment(bool isActive) {
    return Container(
      width: 18.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.green500 : AppColors.gray200,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  void _showMentorSelectionSheet() {
    final String targetSubject = _getSubjectFromTestName(widget.testName);
    final List<Map<String, dynamic>> filteredMentors =
        targetSubject == "All"
            ? dummyMentors
            : dummyMentors.where((m) => m["subject"] == targetSubject).toList();

    final Set<int> selectedMentorIndices = {};

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
            final bool hasWarning = selectedMentorIndices.length >= 2;
            final bool isButtonActive = selectedMentorIndices.isNotEmpty;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Mentors",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                        4.hGap,
                        Text(
                          "Specialized in $targetSubject",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.hGap,
                  if (hasWarning)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange500.withAlpha(20),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.orange500.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.orange800,
                            size: 20.sp,
                          ),
                          12.wGap,
                          Expanded(
                            child: Text(
                              "You have selected multiple mentors for these submissions.",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.orange800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  16.hGap,
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300.h),
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          filteredMentors.length,
                          (index) => _buildMentorItem(
                            filteredMentors[index],
                            selectedMentorIndices.contains(index),
                            () => setSheetState(() {
                              if (selectedMentorIndices.contains(index)) {
                                selectedMentorIndices.remove(index);
                              } else {
                                selectedMentorIndices.add(index);
                              }
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  24.hGap,
                  _buildConfirmButton(isButtonActive, () {
                    Navigator.pop(context);
                    final mentorNames = selectedMentorIndices
                        .map((idx) => filteredMentors[idx]["name"])
                        .join(", ");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "${_selectedIndices.length} Submissions assigned to $mentorNames",
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    );
                    setState(() {
                      _selectedIndices.clear();
                    });
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMentorItem(
    Map<String, dynamic> mentor,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.gray200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: CircleAvatar(
          radius: 18.r,
          backgroundColor:
              isSelected ? AppColors.primary : AppColors.primary.withAlpha(25),
          child: Text(
            mentor["name"][0],
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          mentor["name"],
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        trailing: Icon(
          isSelected
              ? Icons.check_circle_rounded
              : Icons.add_circle_outline_rounded,
          color: AppColors.primary,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildConfirmButton(bool isActive, VoidCallback onTap) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1.0 : 0.6,
      child: Container(
        height: 56.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isActive ? onTap : null,
            borderRadius: BorderRadius.circular(16.r),
            child: const Center(
              child: Text(
                "Confirm Assignment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.gray400,
          width: 1.5,
        ),
      ),
      child:
          isSelected
              ? Icon(Icons.check, color: Colors.white, size: 16.sp)
              : null,
    );
  }

  Widget _buildFloatingButton() {
    final bool isActive = _selectedIndices.isNotEmpty;
    return Positioned(
      bottom: 24.h,
      left: 20.w,
      right: 20.w,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.6,
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isActive ? () => _showMentorSelectionSheet() : null,
              borderRadius: BorderRadius.circular(16.r),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    12.wGap,
                    Text(
                      "Assign Mentors",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
