import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class PeerSubmissionTile extends StatelessWidget {
  final String userName;
  final String answerSubmittedAgo;
  final String? answerType; // 'text', 'pdf', 'image'
  final String? answerText;
  final String? latestComment;
  final String? previewImageUrl;
  final bool isMe;
  final VoidCallback? onReviewPressed;

  const PeerSubmissionTile({
    super.key,
    required this.userName,
    required this.latestComment,
    required this.answerSubmittedAgo,
    this.answerType = 'text',
    this.answerText,
    this.previewImageUrl,
    this.isMe = false,
    this.onReviewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReviewPressed,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: _getAvatarColor(),
                  child: Text(
                    _getInitials(userName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  isMe ? 'Me' : userName,
                  style: TextStyle(
                    color: isMe ? AppColors.primary : const Color(0xFF1E293B),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Spacer(),

                Text(
                  answerSubmittedAgo,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            _buildAnswerPreview(),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child:
                  latestComment != null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Latest Comment',
                                style: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            latestComment!,
                            style: TextStyle(
                              color: const Color(0xFF334155),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerPreview() {
    switch (answerType) {
      case 'pdf':
        return Container(
          margin: EdgeInsets.only(top: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.red.withAlpha(25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'PDF Answer',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      case 'image':
        if (previewImageUrl != null) {
          return Container(
            margin: EdgeInsets.only(top: 16.h),
            height: 140.h,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                previewImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.black26,
                        size: 30.sp,
                      ),
                    ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      case 'text':
      default:
        if (answerText != null) {
          return Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Text(
              answerText!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: 14.sp,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }

  String _getInitials(String name) {
    if (isMe) return 'ME';
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getAvatarColor() {
    if (isMe) return AppColors.primary;
    final colors = [
      const Color(0xFF1E293B), // Slate
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF0F172A), // Slate Darker
      const Color(0xFFF43F5E), // Rose
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF6366F1), // Indigo
    ];
    return colors[userName.hashCode.abs() % colors.length];
  }
}
