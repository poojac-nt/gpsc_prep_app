import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class PeerSubmissionTile extends StatelessWidget {
  final String userName;
  final String userInitial;
  final String? userStatus;
  final String timeAgo;
  final int reviewCount;
  final String previewText;
  final String? previewImageUrl;
  final bool isFeatured;
  final VoidCallback? onReviewPressed;
  final Color baseColor;

  const PeerSubmissionTile({
    super.key,
    required this.userName,
    required this.userInitial,
    this.userStatus,
    required this.timeAgo,
    this.reviewCount = 0,
    required this.previewText,
    this.previewImageUrl =
        "https://fwsghwropuovskeqyawb.supabase.co/storage/v1/object/public/answers/answers/70_753_164_1761490399381_IMG_20251026_202214.jpg",
    this.isFeatured = false,
    this.onReviewPressed,
    this.baseColor = const Color(0xFF1E293B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                radius: 24.r,
                backgroundColor: baseColor,
                child: Text(
                  userInitial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                userName,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              5.wGap,
              Text(
                timeAgo,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            previewText,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          if (previewImageUrl == null) ...[
            SizedBox(height: 16.h),
            Container(
              height: 80.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: NetworkImage(
                    "https://fwsghwropuovskeqyawb.supabase.co/storage/v1/object/public/answers/answers/70_753_164_1761490399381_IMG_20251026_202214.jpg",
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onReviewPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFeatured ? const Color(0xFF4F46E5) : Colors.white,
                foregroundColor:
                    isFeatured ? Colors.white : const Color(0xFF4F46E5),
                elevation: isFeatured ? 4 : 0,
                shadowColor: const Color(0xFF4F46E5).withAlpha(40),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side:
                      isFeatured
                          ? BorderSide.none
                          : const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Review Answer',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isFeatured) ...[
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 16.sp),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
