import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_constants.dart';

class CustomDropdown extends StatelessWidget {
  CustomDropdown({super.key, required this.items, required this.hintText});

  List<String> items = [];
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(minWidth: double.infinity),
            child: DropdownMenu<String>(
              width: constraints.maxWidth,
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(width: 1),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppBorders.borderRadius,
                  borderSide: BorderSide(width: 1),
                ),
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
              ),
              hintText: hintText,
              dropdownMenuEntries:
                  items
                      .map(
                        (item) => DropdownMenuEntry(value: item, label: item),
                      )
                      .toList(),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.white),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
