import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/data/models/payloads/mentor_assign_payload.dart';
import 'package:gpsc_prep_app/domain/entities/student_list_with_mentor.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_assignment/mentor_assignment_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test_wise_submissions/test_wise_submissions_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AssignMentorDetailScreen extends StatefulWidget {
  final String testName;
  final int testId;

  const AssignMentorDetailScreen({
    super.key,
    required this.testName,
    required this.testId,
  });

  @override
  State<AssignMentorDetailScreen> createState() =>
      _AssignMentorDetailScreenState();
}

class _AssignMentorDetailScreenState extends State<AssignMentorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TestWiseSubmissionsBloc>().add(
      FetchTestWisePendingSubmissions(widget.testId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<TestWiseSubmissionsBloc, TestWiseSubmissionsState>(
        listener: (context, state) {
          if (state is TestWiseSubmissionsLoaded &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TestWiseSubmissionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TestWiseSubmissionsError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.gray500),
                ),
              ),
            );
          } else if (state is TestWiseSubmissionsLoaded) {
            List<StudentListWithMentor> submissions = state.studentsWithMentors;
            final selectedIds = state.selectedSubmissionIds;

            if (submissions.isEmpty) {
              return const Center(
                child: Text(
                  "No pending submissions for this test",
                  style: TextStyle(color: AppColors.gray500),
                ),
              );
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.hGap,
                      _buildSubmissionList(submissions, selectedIds),
                    ],
                  ),
                ),
                _buildFloatingButton(submissions, selectedIds),
              ],
            );
          }
          return const SizedBox.shrink();
        },
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
      title: Text(
        widget.testName,
        style: TextStyle(
          color: AppColors.gray900,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSubmissionList(
    List<StudentListWithMentor> submissions,
    Set<int> selectedIds,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildSubmissionCard(submission, submissions, selectedIds);
      },
    );
  }

  Widget _buildSubmissionCard(
    StudentListWithMentor submission,
    List<StudentListWithMentor> allSubmissions,
    Set<int> selectedIds,
  ) {
    final bool isSelected = selectedIds.contains(submission.submissionId);

    bool isEnabled = true;
    if (selectedIds.isNotEmpty) {
      final firstSelectedId = selectedIds.first;
      final firstSelectedSub = allSubmissions.firstWhere(
        (s) => s.submissionId == firstSelectedId,
      );
      if (firstSelectedSub.assessmentType != submission.assessmentType) {
        isEnabled = false;
      }
    }

    return GestureDetector(
      onTap: () {
        context.read<TestWiseSubmissionsBloc>().add(
          ToggleSubmissionSelection(submission),
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
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
                  submission.studentName[0],
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
                        Expanded(
                          child: Text(
                            submission.studentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                submission.assessmentType ==
                                        AssessmentType.double
                                    ? AppColors.orange500.withAlpha(30)
                                    : AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            submission.assessmentType.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color:
                                  submission.assessmentType ==
                                          AssessmentType.double
                                      ? AppColors.orange800
                                      : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    4.hGap,
                    Text(
                      "Submitted on: ${submission.submittedAt.toFormattedDate()}",
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
            ],
          ),
        ),
      ),
    );
  }

  void _showMentorSelectionSheet(
    List<StudentListWithMentor> submissions,
    Set<int> selectedSubIds,
  ) {
    List<Mentor> availableMentors = [];
    bool isFirst = true;

    for (var sub in submissions) {
      if (selectedSubIds.contains(sub.submissionId)) {
        if (isFirst) {
          availableMentors = List.from(sub.mentors);
          isFirst = false;
        } else {
          // Intersection: keep only mentors that are in the current submission's list
          final currentSubMentorIds = sub.mentors.map((m) => m.mentorId).toSet();
          availableMentors.removeWhere(
            (m) => !currentSubMentorIds.contains(m.mentorId),
          );
        }
      }
    }

    final Set<int> alreadyAssignedMentorIds = {};

    for (var sub in submissions) {
      if (selectedSubIds.contains(sub.submissionId)) {
        for (var mentor in sub.assignedMentors) {
          alreadyAssignedMentorIds.add(mentor.mentorId);
        }
      }
    }
    AssessmentType? commonAssessmentType;
    for (var sub in submissions) {
      if (selectedSubIds.contains(sub.submissionId)) {
        commonAssessmentType = sub.assessmentType;
        break;
      }
    }

    final int maxMentors =
        commonAssessmentType == AssessmentType.double ? 2 : 1;
    final Set<int> selectedMentorIds = {};
    final totalSelected =
        alreadyAssignedMentorIds.length + selectedMentorIds.length;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bool isLimitReached = selectedMentorIds.length >= maxMentors;
            final bool isButtonActive = selectedMentorIds.isNotEmpty;

            return BlocListener<MentorAssignmentBloc, MentorAssignmentState>(
              listener: (context, state) {
                if (state is MentorsAssignedSuccessfully) {
                  Navigator.pop(bottomSheetContext); // Close sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Mentors assigned successfully!"),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  );
                  // Clear selection in Bloc
                  context.read<TestWiseSubmissionsBloc>().add(
                    ClearSubmissionSelection(),
                  );
                  // Refresh the list
                  context.read<TestWiseSubmissionsBloc>().add(
                    FetchTestWisePendingSubmissions(widget.testId),
                  );
                } else if (state is MentorAssignmentError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: Container(
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
                            "Select Mentors ($totalSelected/$maxMentors)",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gray900,
                            ),
                          ),
                          4.hGap,
                          Text(
                            "${availableMentors.length} mentors available • ${commonAssessmentType?.type ?? "Assessment"}",
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
                    if (isLimitReached && maxMentors == 1)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            12.wGap,
                            Expanded(
                              child: Text(
                                "Single assessment allows only 1 mentor.",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isLimitReached && maxMentors == 2)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        margin: EdgeInsets.only(bottom: 16.h),
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
                                "Double assessment allows maximum 2 mentors.",
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
                          children: List.generate(availableMentors.length, (
                            index,
                          ) {
                            final mentor = availableMentors[index];
                            final bool isAssigned = alreadyAssignedMentorIds
                                .contains(mentor.mentorId);
                            final remainingMentors =
                                maxMentors - alreadyAssignedMentorIds.length;
                            return _buildMentorItem(
                              availableMentors[index],
                              selectedMentorIds.contains(
                                availableMentors[index].mentorId,
                              ),
                              isAssigned,
                              () => setSheetState(() {
                                if (isAssigned) return;
                                final int mentorId =
                                    availableMentors[index].mentorId;
                                if (selectedMentorIds.contains(mentorId)) {
                                  selectedMentorIds.remove(mentorId);
                                } else {
                                  if (maxMentors == 1) {
                                    // Replace selection for single assessment
                                    selectedMentorIds.clear();
                                    selectedMentorIds.add(mentorId);
                                  } else if (selectedMentorIds.length <
                                      remainingMentors) {
                                    selectedMentorIds.add(mentorId);
                                  } else {
                                    // Limit reached for multiple
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Maximum $maxMentors mentors allowed for this assessment type.",
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                }
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                    24.hGap,
                    _buildConfirmButton(isButtonActive, () {
                      final List<MentorAssignmentPayload> payloads = [];
                      for (var subId in selectedSubIds) {
                        for (var mentorId in selectedMentorIds) {
                          payloads.add(
                            MentorAssignmentPayload(
                              submissionId: subId,
                              mentorId: mentorId,
                              assignedBy: getIt<CacheManager>().getUserId(),
                            ),
                          );
                        }
                      }
                      context.read<MentorAssignmentBloc>().add(
                        AssignMentorsToSubmissions(payloads),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMentorItem(
    Mentor mentor,
    bool isSelected,
    bool isAssigned,
    VoidCallback onTap,
  ) {
    return Opacity(
      opacity: isAssigned ? 0.5 : 1,
      child: Container(
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
                isSelected
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(25),
            child: Text(
              mentor.mentorName[0],
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            mentor.mentorName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          trailing:
              isAssigned
                  ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Assigned",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                  : Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
          onTap: isAssigned ? null : onTap,
        ),
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

  Widget _buildFloatingButton(
    List<StudentListWithMentor> submissions,
    Set<int> selectedIds,
  ) {
    final bool isActive = selectedIds.isNotEmpty;
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
              onTap:
                  isActive
                      ? () =>
                          _showMentorSelectionSheet(submissions, selectedIds)
                      : null,
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
