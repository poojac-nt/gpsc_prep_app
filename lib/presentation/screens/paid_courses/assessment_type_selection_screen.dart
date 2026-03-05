import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../domain/entities/course_model.dart';

class AssessmentTypeSelectionScreen extends StatefulWidget {
  final CourseModel courseModel;
  const AssessmentTypeSelectionScreen({super.key, required this.courseModel});

  @override
  State<AssessmentTypeSelectionScreen> createState() =>
      _AssessmentTypeSelectionScreenState();
}

class _AssessmentTypeSelectionScreenState
    extends State<AssessmentTypeSelectionScreen> {
  AssessmentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
        ),
        title: Text(
          "Select Assessment Type",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose how you want your descriptive answers to be evaluated.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  24.hGap,
                  _buildOptionCard(
                    type: AssessmentType.single,
                    title: "Single Assessment",
                    price: widget.courseModel.priceSingle ?? 0,
                    description:
                        "Your answers will be evaluated once by a verified mentor with detailed feedback.",
                    icon: Icons.person_outline_rounded,
                  ),
                  16.hGap,
                  _buildOptionCard(
                    type: AssessmentType.double,
                    title: "Double Assessment",
                    price: widget.courseModel.priceDual ?? 0,
                    description:
                        "Get your answers reviewed by two different mentors for more comprehensive insights.",
                    icon: Icons.people_outline_rounded,
                  ),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required AssessmentType type,
    required String title,
    required String description,
    required IconData icon,
    required int price,
  }) {
    final bool isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(5) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary.withAlpha(20)
                            : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade600,
                    size: 24.sp,
                  ),
                ),
                16.wGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      8.hGap,
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      8.hGap,
                      Text(
                        "₹$price",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: ActionButton(
          text: "Proceed to Payment",
          onTap:
              _selectedType == null
                  ? null
                  : () {
                    // For now, just a placeholder action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Selected: ${_selectedType!.type}"),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
        ),
      ),
    );
  }
}
