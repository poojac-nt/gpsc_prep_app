import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({
    super.key,
    required this.child,
    this.radius,
    this.borderColor,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = Colors.transparent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius ?? AppBorders.borderRadius,
        border: Border.all(color: borderColor ?? Colors.black, width: 2),
      ),
      padding: padding,
      child: child,
    );
  }
}
