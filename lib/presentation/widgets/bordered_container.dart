import 'package:flutter/material.dart';

import '../../utils/app_constants.dart';

class BorderedContainer extends StatelessWidget {
  const BorderedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius ?? AppBorders.borderRadius,
        border: Border.all(color: borderColor ?? Colors.black, width: 2),
      ),
      padding: padding,
      child: child,
    );
  }
}
