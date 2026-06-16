import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AdminCourseDetailsScreen extends StatefulWidget {
  const AdminCourseDetailsScreen({super.key, required this.courseModel});

  final CourseModel courseModel;

  @override
  State<AdminCourseDetailsScreen> createState() => _AdminCourseDetailsScreenState();
}

class _AdminCourseDetailsScreenState extends State<AdminCourseDetailsScreen> {
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.courseModel.isActive ?? false;
  }

  Future<void> _toggleStatus() async {
    setState(() {
      _isLoading = true;
    });

    final helper = getIt<SupabaseHelper>();
    final newValue = !_isActive;
    
    final result = await helper.toggleCourseActive(
      courseId: widget.courseModel.id,
      isActive: newValue,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          setState(() {
            _isActive = newValue;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Course ${newValue ? "activated" : "deactivated"} successfully',
              ),
              backgroundColor: newValue ? Colors.green : Colors.orange,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prelims = widget.courseModel.tests?.prelims ?? [];
    final descriptive = widget.courseModel.tests?.descriptive ?? [];
    final totalTests = prelims.length + descriptive.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        ),
        title: Text(
          "Course Details (Admin)",
          style: AppTexts.titleTextStyle.copyWith(fontSize: 18.sp),
        ),
        elevation: 0,
        backgroundColor: AppColors.scaffoldColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            16.hGap,
            
            // Course Info section
            _buildCourseHeader(),
            20.hGap,

            // Pricing Info Grid
            _buildMetadataGrid(totalTests),
            24.hGap,

            // Action Button
            _buildActionButton(),
            28.hGap,

            // Curriculum/Tests lists
            _buildCurriculumSection(prelims, descriptive),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: _isActive
            ? const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: (_isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280))
                .withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isActive ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isActive ? "Course is Active" : "Course is Inactive",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                4.hGap,
                Text(
                  _isActive
                      ? "Visible to students. They can view details and enroll."
                      : "Hidden from students. They cannot view or purchase.",
                  style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.courseModel.testType?.name.toUpperCase() ?? "COURSE",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              12.wGap,
              Text(
                'ID: #${widget.courseModel.id}',
                style: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          14.hGap,
          Text(
            widget.courseModel.name,
            style: AppTexts.titleTextStyle.copyWith(fontSize: 22.sp),
          ),
          12.hGap,
          Text(
            widget.courseModel.description,
            style: AppTexts.subTitle.copyWith(
              color: AppColors.gray700,
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataGrid(int totalTests) {
    final singlePrice = widget.courseModel.singleProduct.price;
    final dualPrice = widget.courseModel.dualProduct?.price;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14.w,
      mainAxisSpacing: 14.w,
      childAspectRatio: 1.6,
      children: [
        _buildMetadataCard(
          title: "Single Price",
          value: singlePrice > 0 ? "₹$singlePrice" : "Free",
          icon: Icons.sell_rounded,
          color: Colors.blue,
        ),
        _buildMetadataCard(
          title: "Dual Price",
          value: dualPrice != null && dualPrice > 0 ? "₹$dualPrice" : "N/A",
          icon: Icons.dynamic_feed_rounded,
          color: Colors.purple,
        ),
        _buildMetadataCard(
          title: "Total Tests",
          value: "$totalTests",
          icon: Icons.quiz_rounded,
          color: Colors.orange,
        ),
        _buildMetadataCard(
          title: "Course Type",
          value: widget.courseModel.testType?.name.toUpperCase() ?? "PRELIMS",
          icon: Icons.category_rounded,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMetadataCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18.sp),
              8.wGap,
              Text(
                title,
                style: AppTexts.subTitle.copyWith(
                  color: AppColors.gray500,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          10.hGap,
          Text(
            value,
            style: AppTexts.heading.copyWith(
              fontSize: 16.sp,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _toggleStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
          shadowColor: (_isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withAlpha(100),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 20.sp,
                  ),
                  10.wGap,
                  Text(
                    _isActive ? "Deactivate Course" : "Activate Course",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCurriculumSection(List<dynamic> prelims, List<dynamic> descriptive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Course Curriculum",
          style: AppTexts.heading.copyWith(fontSize: 16.sp, color: AppColors.gray900),
        ),
        14.hGap,
        if (prelims.isEmpty && descriptive.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(
              child: Text("No tests added to this course yet."),
            ),
          )
        else ...[
          if (prelims.isNotEmpty) ...[
            _buildSectionHeader("Prelims Tests (${prelims.length})"),
            8.hGap,
            ...prelims.map((test) => _buildTestItem(
                  name: test.name,
                  info: "${test.duration} Mins • ${test.totalMarks} Marks",
                  icon: Icons.quiz_rounded,
                  iconColor: Colors.blue,
                )),
            16.hGap,
          ],
          if (descriptive.isNotEmpty) ...[
            _buildSectionHeader("Descriptive Tests (${descriptive.length})"),
            8.hGap,
            ...descriptive.map((test) => _buildTestItem(
                  name: test.name,
                  info: "${test.noQuestions} Questions",
                  icon: Icons.description_rounded,
                  iconColor: Colors.purple,
                )),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Text(
        title,
        style: AppTexts.title.copyWith(
          color: AppColors.gray700,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildTestItem({
    required String name,
    required String info,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTexts.title.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.gray900,
                  ),
                ),
                4.hGap,
                Text(
                  info,
                  style: AppTexts.subTitle.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
