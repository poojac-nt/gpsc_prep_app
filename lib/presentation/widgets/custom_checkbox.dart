import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_constants.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    this.isRounded = false,
    required this.title,
  });
  final bool value;
  final String title;
  final bool isRounded;
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
          onChanged: (value) {},
          fillColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return Colors.black;
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
