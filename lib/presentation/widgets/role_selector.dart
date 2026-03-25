import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';

class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "I am a",
          style: AppTexts.labelTextStyle.copyWith(
            color: Colors.grey[800],
            fontSize: 14.sp,
          ),
        ),
        8.hGap,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              _buildRoleOption(UserRole.student, "Student"),
              _buildRoleOption(UserRole.mentor, "Mentor"),
              _buildRoleOption(UserRole.admin, "Admin"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(UserRole role, String label) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on num {
  Widget get hGap => SizedBox(height: toDouble().h);
}
