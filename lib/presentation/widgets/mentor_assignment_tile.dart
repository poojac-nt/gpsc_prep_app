import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/status_badge.dart';

class MentorAssignmentTile extends StatelessWidget {
  const MentorAssignmentTile({
    super.key,
    required this.studentName,
    required this.testTitle,
    required this.status,
    required this.date,
    required this.actionText,
    required this.onActionTap,
  });

  final String studentName;
  final String testTitle;
  final String status;
  final String date;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  _getInitials(studentName),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        StatusBadge(
                          label: status.toUpperCase(),
                          backgroundColor: _getStatusBgColor(status),
                          color: _getStatusTextColor(status),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      testTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
              SizedBox(
                height: 36.h,
                child: ElevatedButton(
                  onPressed: onActionTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActionColor(status),
                    foregroundColor:
                        status.toLowerCase() == 'evaluated'
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side:
                          status.toLowerCase() == 'evaluated'
                              ? const BorderSide(color: Color(0xFF4F46E5))
                              : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "";
    final parts = name.split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'in progress':
        return const Color(0xFFDBEAFE);
      case 'evaluated':
        return const Color(0xFFD1FAE5);
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD97706);
      case 'in progress':
        return const Color(0xFF2563EB);
      case 'evaluated':
        return const Color(0xFF059669);
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getActionColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'in progress':
        return const Color(0xFF4F46E5);
      case 'evaluated':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}
