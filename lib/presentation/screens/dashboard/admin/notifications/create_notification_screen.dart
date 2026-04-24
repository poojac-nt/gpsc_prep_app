import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/notification_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/notification/notification_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_text_field.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../../../core/di/di.dart';
import '../../../../../core/helpers/snack_bar_helper.dart';

class CreateNotificationScreen extends StatefulWidget {
  /// If provided, the form will be pre-filled with this notification's data
  /// to allow admins to resend it with a new schedule.
  final NotificationModel? prefill;

  const CreateNotificationScreen({super.key, this.prefill});

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  String _targetAudience = 'all'; // 'all', 'student', 'mentor'
  String _notificationType = 'general'; // 'general', 'course', 'test'
  CourseModel? _selectedCourse;
  _TestOption? _selectedTest;

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationMetadata());
    // Pre-fill if resending a past notification
    final prefill = widget.prefill;
    if (prefill != null) {
      _titleController.text = prefill.title;
      _bodyController.text = prefill.body;
      _targetAudience = prefill.targetAudience;
      _notificationType = prefill.type;
    }
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state.status == NotificationStatus.success) {
          context.pop();
        }
        // Once metadata is loaded, pre-select the linked course/test from prefill
        if (state.status == NotificationStatus.metadataLoaded &&
            widget.prefill != null) {
          _applyPrefillSelection(state);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff8f9fb),
        appBar: AppBar(
          title: Text(
            'Create Notification',
            style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
          ),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final courses = state.metadata?.courses ?? [];
            final tests = _getMergedTests(state.metadata);

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Broadcast",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    5.hGap,
                    Text(
                      "Dispatch Alert",
                      style: TextStyle(
                        color: const Color(0xff1f2937),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    5.hGap,
                    Container(
                      width: 40.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    25.hGap,
                    _buildSectionCard(
                      title: "TARGET AUDIENCE",
                      child: Row(
                        children: [
                          _buildAudienceOption(
                            label: "All Users",
                            value: 'all',
                            icon: Icons.public,
                          ),
                          10.wGap,
                          _buildAudienceOption(
                            label: "Students",
                            value: 'student',
                            icon: Icons.school,
                          ),
                          10.wGap,
                          _buildAudienceOption(
                            label: "Mentors",
                            value: 'mentor',
                            icon: Icons.person,
                          ),
                        ],
                      ),
                    ),
                    15.hGap,
                    _buildSectionCard(
                      title: "NOTIFICATION TYPE",
                      child: Row(
                        children: [
                          _buildSelectOption(
                            label: "General",
                            value: 'general',
                            isSelected: _notificationType == 'general',
                            icon: Icons.notifications_none,
                            onTap:
                                () => setState(() {
                                  _notificationType = 'general';
                                  _selectedCourse = null;
                                  _selectedTest = null;
                                }),
                          ),
                          10.wGap,
                          _buildSelectOption(
                            label: "Course",
                            value: 'course',
                            isSelected: _notificationType == 'course',
                            icon: Icons.book_outlined,
                            onTap:
                                () => setState(() {
                                  _notificationType = 'course';
                                  _selectedTest = null;
                                }),
                          ),
                          10.wGap,
                          _buildSelectOption(
                            label: "Test",
                            value: 'test',
                            isSelected: _notificationType == 'test',
                            icon: Icons.quiz_outlined,
                            onTap:
                                () => setState(() {
                                  _notificationType = 'test';
                                  _selectedCourse = null;
                                }),
                          ),
                        ],
                      ),
                    ),
                    15.hGap,

                    if (_notificationType != 'general') ...[
                      15.hGap,
                      _buildSectionCard(
                        title:
                            _notificationType == 'course'
                                ? "COURSE SELECTION"
                                : "TEST SELECTION",
                        child:
                            _notificationType == 'course'
                                ? _buildDropdown<CourseModel>(
                                  hint: "Select a course...",
                                  value: _selectedCourse,
                                  items:
                                      courses.map((e) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            e.name,
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        );
                                      }).toList(),
                                  selectedItemBuilder: (context) {
                                    return courses.map((e) {
                                      return Text(
                                        e.name,
                                        style: TextStyle(fontSize: 14.sp),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    }).toList();
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCourse = val;
                                    });
                                  },
                                )
                                : _buildTestPickerField(tests),
                      ),
                    ],
                    15.hGap,
                    _buildSectionCard(
                      title: "NOTIFICATION TITLE",
                      child: CustomTextField(
                        controller: _titleController,
                        hintText: "Enter broadcast title...",
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                      ),
                    ),
                    15.hGap,
                    _buildSectionCard(
                      title: "NOTIFICATION BODY",
                      trailing: Text(
                        "${_bodyController.text.length}/500",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10.sp,
                        ),
                      ),
                      child: CustomTextField(
                        controller: _bodyController,
                        hintText: "Compose your message for students...",
                        maxLine: 5,
                        // onChanged: (val) => setState(() {}),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                      ),
                    ),
                    15.hGap,

                    _buildSectionCard(
                      title: "RELEASE DATE",
                      child: CustomTextField(
                        controller: _dateController,
                        hintText: "mm/dd/yyyy",
                        suffixIcon: Icon(
                          Icons.calendar_today_outlined,
                          size: 20.sp,
                          color: Colors.black87,
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                      ),
                      onTap: _selectDate,
                    ),

                    15.hGap,

                    _buildSectionCard(
                      title: "RELEASE TIME",
                      child: CustomTextField(
                        controller: _timeController,
                        hintText: "--:-- --",
                        suffixIcon: Icon(
                          Icons.access_time,
                          size: 20.sp,
                          color: Colors.black87,
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                      ),
                      onTap: _selectTime,
                    ),

                    30.hGap,

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed:
                            state.status == NotificationStatus.submitting
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_notificationType == 'course' &&
                                        _selectedCourse == null) {
                                      getIt<SnackBarHelper>().showError(
                                        "Please select a course",
                                      );
                                      return;
                                    }
                                    if (_notificationType == 'test' &&
                                        _selectedTest == null) {
                                      getIt<SnackBarHelper>().showError(
                                        "Please select a test",
                                      );
                                      return;
                                    }

                                    debugPrint(
                                      "Form validated, preparing notification...",
                                    );
                                    final notification = NotificationModel(
                                      id: widget.prefill?.id,
                                      title: _titleController.text.trim(),
                                      body: _bodyController.text.trim(),
                                      scheduledAt: _getScheduledDateTime(),
                                      type: _notificationType,
                                      referenceId:
                                          _selectedCourse?.id ??
                                          _selectedTest?.id,
                                      testType: _selectedTest?.type,
                                      targetAudience: _targetAudience,
                                    );
                                    if (widget.prefill != null && widget.prefill!.id != null) {
                                      debugPrint(
                                        "Dispatching UpdateNotificationEvent: ${notification.toJson()}",
                                      );
                                      context.read<NotificationBloc>().add(
                                        UpdateNotificationEvent(notification),
                                      );
                                    } else {
                                      debugPrint(
                                        "Dispatching CreateNotificationEvent: ${notification.toJson()}",
                                      );
                                      context.read<NotificationBloc>().add(
                                        CreateNotificationEvent(notification),
                                      );
                                    }
                                  } else {
                                    debugPrint("Form validation failed.");
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0056b3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                        ),
                        child:
                            state.status == NotificationStatus.submitting
                                ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    10.wGap,
                                    Text(
                                      widget.prefill != null
                                          ? 'Update Broadcast'
                                          : 'Schedule Broadcast',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    20.hGap,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime _getScheduledDateTime() {
    try {
      if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
        return DateTime.now();
      }

      // Date: mm/dd/yyyy
      final dateParts = _dateController.text.split('/');
      final month = int.parse(dateParts[0]);
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Time: hh:mm AM/PM (from TimeOfDay.format)
      final timeStr = _timeController.text;
      final isPM = timeStr.contains('PM');
      final timeParts = timeStr
          .replaceAll(' AM', '')
          .replaceAll(' PM', '')
          .split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute).toUtc();
    } catch (e) {
      return DateTime.now().toUtc();
    }
  }

  /// Called after metadata loads when resending a past notification.
  /// Matches [prefill.referenceId] to a course or test and pre-selects it.
  void _applyPrefillSelection(NotificationState state) {
    final prefill = widget.prefill;
    if (prefill == null || prefill.referenceId == null) return;

    final refId = prefill.referenceId!;

    if (prefill.type == 'course') {
      final courses = state.metadata?.courses ?? [];
      final match = courses.cast<CourseModel?>().firstWhere(
        (c) => c?.id == refId,
        orElse: () => null,
      );
      if (match != null && mounted) {
        setState(() => _selectedCourse = match);
      }
    } else if (prefill.type == 'test') {
      final tests = _getMergedTests(state.metadata);
      final match = tests.cast<_TestOption?>().firstWhere(
        (t) => t?.id == refId && t?.type == (prefill.testType ?? ''),
        orElse: () => null,
      );
      if (match != null && mounted) {
        setState(() => _selectedTest = match);
      }
    }
  }

  List<_TestOption> _getMergedTests(AllTestsModel? metadata) {
    if (metadata == null) return [];
    return [
      ...metadata.mcq.map(
        (e) => _TestOption(
          id: e.id,
          name: e.name,
          type: 'mcq',
          label: "MCQ",
          color: Colors.blue,
        ),
      ),
      ...metadata.descriptive.map(
        (e) => _TestOption(
          id: e.id,
          name: e.name,
          type: 'desc',
          label: "DESC",
          color: Colors.green,
        ),
      ),
    ];
  }

  /// Tappable field that opens the searchable test picker bottom sheet.
  Widget _buildTestPickerField(List<_TestOption> tests) {
    return GestureDetector(
      onTap: () => _showTestSearchPicker(tests),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        height: 52.h,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child:
                  _selectedTest == null
                      ? Text(
                        "Search and select a test...",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13.sp,
                        ),
                      )
                      : Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedTest!.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: _selectedTest!.color.withAlpha(50),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _selectedTest!.label,
                              style: TextStyle(
                                color: _selectedTest!.color,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          8.wGap,
                          Expanded(
                            child: Text(
                              _selectedTest!.name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
            ),
            if (_selectedTest != null)
              GestureDetector(
                onTap: () => setState(() => _selectedTest = null),
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey[500]),
              )
            else
              Icon(Icons.search, size: 18.sp, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showTestSearchPicker(List<_TestOption> allTests) {
    final searchController = TextEditingController();
    List<_TestOption> filtered = List.from(allTests);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Select a Test",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff1f2937),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${filtered.length} results",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Search tests...",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20.sp,
                            color: Colors.grey[400],
                          ),
                          suffixIcon:
                              searchController.text.isNotEmpty
                                  ? GestureDetector(
                                    onTap: () {
                                      searchController.clear();
                                      setModalState(() {
                                        filtered = List.from(allTests);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 18.sp,
                                      color: Colors.grey[400],
                                    ),
                                  )
                                  : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            filtered =
                                allTests
                                    .where(
                                      (t) => t.name.toLowerCase().contains(
                                        query.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                          });
                        },
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    // List
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 40.sp,
                                      color: Colors.grey[300],
                                    ),
                                    12.hGap,
                                    Text(
                                      "No tests found",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                separatorBuilder:
                                    (_, _) => Divider(
                                      height: 1,
                                      color: Colors.grey[100],
                                      indent: 16.w,
                                      endIndent: 16.w,
                                    ),
                                itemBuilder: (_, index) {
                                  final test = filtered[index];
                                  final isSelected =
                                      _selectedTest?.id == test.id &&
                                      _selectedTest?.type == test.type;
                                  return InkWell(
                                    onTap: () {
                                      setState(() => _selectedTest = test);
                                      Navigator.pop(ctx);
                                    },
                                    child: Container(
                                      color:
                                          isSelected
                                              ? AppColors.primary.withAlpha(10)
                                              : null,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: test.color.withAlpha(20),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                              border: Border.all(
                                                color: test.color.withAlpha(50),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              test.label,
                                              style: TextStyle(
                                                color: test.color,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          12.wGap,
                                          Expanded(
                                            child: Text(
                                              test.name,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                color:
                                                    isSelected
                                                        ? AppColors.primary
                                                        : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                              size: 18.sp,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            12.hGap,
            InkWell(
              onTap: isEnabled ? onTap : null,
              child: IgnorePointer(
                ignoring: (onTap != null || !isEnabled),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return _buildSelectOption(
      label: label,
      value: value,
      isSelected: _targetAudience == value,
      icon: icon,
      onTap: () => setState(() => _targetAudience = value),
    );
  }

  Widget _buildSelectOption({
    required String label,
    required String value,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withAlpha(20) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: isSelected ? AppColors.primary : Colors.grey[400],
              ),
              6.hGap,
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T?>> items,
    required ValueChanged<T?> onChanged,
    DropdownButtonBuilder? selectedItemBuilder,
    bool isEnabled = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        height: 52.h,
        alignment: Alignment.center,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T?>(
            dropdownColor: Colors.white,
            value: value,
            itemHeight:
                null, // Allow items to have their own height in the menu
            isDense: true, // Keep the button compact
            hint: Text(
              hint,
              style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
            isExpanded: true,
            items: items,
            selectedItemBuilder: selectedItemBuilder,
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

class _TestOption extends Equatable {
  final int id;
  final String name;
  final String type;
  final String label;
  final Color color;

  const _TestOption({
    required this.id,
    required this.name,
    required this.type,
    required this.label,
    required this.color,
  });

  @override
  List<Object?> get props => [id, type, label];
}
