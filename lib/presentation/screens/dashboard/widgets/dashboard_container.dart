import 'package:flutter/material.dart';

import '../../../../utils/app_constants.dart';

class DashboardContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final LinearGradient? gradient;

  const DashboardContainer({
    super.key,
    this.padding,
    this.height,
    required this.child,
    this.color = Colors.white,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? EdgeInsets.all(AppPaddings.dashboardContainerPadding),
      decoration: BoxDecoration(
        borderRadius: AppBorders.dashboardBorderRadius,
        color: color,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            spreadRadius: 5,
            blurRadius: 7,
          ),
        ],
        border: Border.all(color: Colors.grey, width: 0.1),
      ),
      child: child,
    );
  }
}
