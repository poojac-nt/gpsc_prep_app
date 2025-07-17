import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_constants.dart';

class CustomCheckbox extends StatelessWidget {
  CustomCheckbox({
    super.key,
    required this.value,
    this.isRounded = false,
    required this.title,
    required this.onTap,
  });

  bool value;
  final String title;
  final bool isRounded;
  final ValueChanged<bool?> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          shape:
              isRounded
                  ? RoundedRectangleBorder(
                    borderRadius: AppBorders.borderRadius,
                    side: BorderSide(color: Colors.green, width: 1),
                  )
                  : null,
          value: value,
          onChanged: onTap,
          fillColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.white;
          }),
          checkColor: Colors.white,
        ),
        Expanded(
          child: Text(
            maxLines: 2,
            title,
            style: AppTexts.labelTextStyle.copyWith(fontSize: 13.sp),
          ),
        ),
      ],
    );
  }
}
