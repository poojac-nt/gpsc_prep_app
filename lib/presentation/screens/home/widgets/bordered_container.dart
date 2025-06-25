import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/stats_widget.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

import '../../../../utils/app_constants.dart';

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppBorders.borderRadius,
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: padding,
      child: child,
    );
  }
}
