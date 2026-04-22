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

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

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
  CourseModel? _selectedCourse;
  _TestOption? _selectedTest;

  @override
  void initState() {
    context.read<NotificationBloc>().add(FetchNotificationMetadata());
    super.initState();
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
                      title: "COURSE SELECTION",
                      child: _buildDropdown<CourseModel>(
                        hint: "General Notification (No course selected)",
                        value: _selectedCourse,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("General Notification"),
                          ),
                          ...courses.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.name,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            );
                          }),
                        ],
                        selectedItemBuilder: (context) {
                          return [
                            const Text("General Notification"),
                            ...courses.map((e) {
                              return Text(
                                e.name,
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ];
                        },
                        onChanged: (val) {
                          setState(() {
                            _selectedCourse = val;
                            if (val != null) _selectedTest = null;
                          });
                        },
                      ),
                    ),
                    15.hGap,
                    _buildSectionCard(
                      title: "TEST SELECTION",
                      child: _buildDropdown<_TestOption>(
                        hint: "General Notification (No test selected)",
                        value: _selectedTest,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("General Notification"),
                          ),
                          ...tests.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      e.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    6.hGap,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: e.color.withAlpha(25),
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                        border: Border.all(
                                          color: e.color.withAlpha(50),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        e.label,
                                        style: TextStyle(
                                          color: e.color,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedTest = val;
                            if (val != null) _selectedCourse = null;
                          });
                        },
                        selectedItemBuilder: (context) {
                          return [
                            const Text("General Notification"),
                            ...tests.map((e) {
                              return Text(
                                e.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ];
                        },
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
                                    debugPrint(
                                      "Form validated, preparing notification...",
                                    );
                                    final notification = NotificationModel(
                                      title: _titleController.text.trim(),
                                      body: _bodyController.text.trim(),
                                      scheduledAt: _getScheduledDateTime(),
                                      type:
                                          _selectedCourse != null
                                              ? 'course'
                                              : (_selectedTest != null
                                                  ? 'test'
                                                  : 'general'),
                                      referenceId:
                                          _selectedCourse?.id ??
                                          _selectedTest?.id,
                                      testType: _selectedTest?.type,
                                      targetAudience: _targetAudience,
                                    );
                                    debugPrint(
                                      "Dispatching CreateNotificationEvent: ${notification.toJson()}",
                                    );
                                    context.read<NotificationBloc>().add(
                                      CreateNotificationEvent(notification),
                                    );
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
                                      "Create Notification",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
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
          label: "DESCRIPTIVE",
          color: Colors.green,
        ),
      ),
    ];
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
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
            onTap: onTap,
            child: IgnorePointer(ignoring: onTap != null, child: child),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _targetAudience == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _targetAudience = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(20) : Colors.grey[100],
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
            onChanged: onChanged,
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
