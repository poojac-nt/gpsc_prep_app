import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmissionStatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initials;
  final VoidCallback? onView;
  final Color baseColor;

  const SubmissionStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.initials,
    this.onView,
    this.baseColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: baseColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: baseColor,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onView != null)
            TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: baseColor.withOpacity(0.1)),
                ),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  color: const Color(0xFF4F46E5),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
