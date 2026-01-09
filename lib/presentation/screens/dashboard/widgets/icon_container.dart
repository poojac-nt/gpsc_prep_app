import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final BorderRadius borderRadius;
  final IconData icon;
  final Color color;
  const IconContainer({
    super.key,
    required this.borderRadius,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color.withAlpha(30),
      ),
      child: Icon(icon, color: color),
    );
  }
}
