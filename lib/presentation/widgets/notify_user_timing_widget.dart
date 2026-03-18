import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class NotifyUserTimingController {
  final isLaterNotifier = ValueNotifier<bool>(false);
  final selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final selectedTimeNotifier = ValueNotifier<TimeOfDay>(TimeOfDay.now());

  DateTime get availableAt {
    if (!isLaterNotifier.value) {
      return DateTime.now().toUtc();
    }
    return DateTime(
      selectedDateNotifier.value.year,
      selectedDateNotifier.value.month,
      selectedDateNotifier.value.day,
      selectedTimeNotifier.value.hour,
      selectedTimeNotifier.value.minute,
    ).toUtc();
  }

  void dispose() {
    isLaterNotifier.dispose();
    selectedDateNotifier.dispose();
    selectedTimeNotifier.dispose();
  }
}

class NotifyUserTimingWidget extends StatelessWidget {
  final NotifyUserTimingController controller;

  const NotifyUserTimingWidget({
    super.key,
    required this.controller,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateNotifier.value,
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
    if (picked != null && picked != controller.selectedDateNotifier.value) {
      controller.selectedDateNotifier.value = picked;
      // If today is selected, ensure time is not in the past
      final now = DateTime.now();
      final isToday = picked.year == now.year &&
          picked.month == now.month &&
          picked.day == now.day;
      if (isToday && !_isTimeAfterNow(controller.selectedTimeNotifier.value)) {
        controller.selectedTimeNotifier.value = TimeOfDay.now();
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();
    final selectedDate = controller.selectedDateNotifier.value;
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    final selectedTime = controller.selectedTimeNotifier.value;
    // Create a DateTime from selectedDate and current selectedTime
    DateTime initialDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // If today is selected and initial time is in the past, reset to now plus buffer
    if (isToday && initialDateTime.isBefore(now)) {
      initialDateTime = now.add(const Duration(minutes: 1));
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250.h,
        padding: const EdgeInsets.only(top: 6.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Select Time',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialDateTime,
                minimumDate: isToday
                    ? DateTime(
                        now.year,
                        now.month,
                        now.day,
                        now.hour,
                        now.minute,
                      )
                    : null,
                onDateTimeChanged: (DateTime newDateTime) {
                  controller.selectedTimeNotifier.value =
                      TimeOfDay.fromDateTime(newDateTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isTimeAfterNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    return time.hour > now.hour ||
        (time.hour == now.hour && time.minute > now.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 0.h, bottom: 10.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Notify User',
                style: AppTexts.labelTextStyle.copyWith(fontSize: 16.sp),
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isLaterNotifier,
                builder: (context, isLater, child) {
                  return Row(
                    children: [
                      _buildToggleButton(
                        'Immediate',
                        !isLater,
                        () => controller.isLaterNotifier.value = false,
                      ),
                      8.wGap,
                      _buildToggleButton(
                        'Later',
                        isLater,
                        () => controller.isLaterNotifier.value = true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLaterNotifier,
            builder: (context, isLater, child) {
              if (!isLater) return const SizedBox.shrink();
              return Column(
                children: [
                  15.hGap,
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<DateTime>(
                          valueListenable: controller.selectedDateNotifier,
                          builder: (context, date, child) {
                            return _buildPickerTile(
                              icon: Icons.calendar_today,
                              label: 'Date',
                              value: DateFormat('MMM dd, yyyy').format(date),
                              onTap: () => _selectDate(context),
                            );
                          },
                        ),
                      ),
                      12.wGap,
                      Expanded(
                        child: ValueListenableBuilder<TimeOfDay>(
                          valueListenable: controller.selectedTimeNotifier,
                          builder: (context, time, child) {
                            return _buildPickerTile(
                              icon: Icons.access_time,
                              label: 'Time',
                              value: time.format(context),
                              onTap: () => _selectTime(context),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primary),
            10.wGap,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
