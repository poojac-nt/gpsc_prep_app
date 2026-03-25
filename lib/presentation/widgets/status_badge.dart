import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? const Color(0xFF2563EB);
    final bgColor = backgroundColor ?? const Color(0xFFDBEAFE);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  /// Named constructors for common statuses
  factory StatusBadge.inProgress() => const StatusBadge(
    label: 'In Progress',
    color: Color(0xFF2563EB),
    backgroundColor: Color(0xFFDBEAFE),
  );

  factory StatusBadge.evaluated() => const StatusBadge(
    label: 'Evaluated',
    color: Color(0xFF059669),
    backgroundColor: Color(0xFFD1FAE5),
  );

  factory StatusBadge.pending() => const StatusBadge(
    label: 'Pending',
    color: Color(0xFFD97706),
    backgroundColor: Color(0xFFFEF3C7),
  );
}
