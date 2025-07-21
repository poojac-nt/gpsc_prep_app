import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({
    super.key,
    required this.child,
    this.radius,
    this.borderColor,
    this.hasBorder = true,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = Colors.transparent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius ?? AppBorders.borderRadius,
        border:
            hasBorder
                ? Border.all(
                  color: borderColor ?? AppColors.accentColor,
                  width: 2,
                )
                : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
