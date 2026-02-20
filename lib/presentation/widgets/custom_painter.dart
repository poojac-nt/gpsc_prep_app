import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Color color;
  CirclePainter({this.color = Colors.blue});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withAlpha(80);
    canvas.drawCircle(
      Offset(size.width, size.height / 6),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
