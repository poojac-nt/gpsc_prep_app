import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

import '../../../widgets/bordered_container.dart';
import '../../../widgets/custom_checkbox.dart';

class ExamPrefTile extends StatelessWidget {
  const ExamPrefTile({
    super.key,
    required this.onChanged,
    required this.title,
    this.value = false,
  });

  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BorderedContainer(
      padding: EdgeInsets.zero,
      radius: BorderRadius.zero,
      borderColor: value ? AppColors.primary : Colors.grey,
      child: CustomCheckbox(value: value, onTap: onChanged, title: title),
    );
  }
}
