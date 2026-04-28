import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';

class GridBg extends StatelessWidget {
  final double opacity;
  const GridBg({super.key, this.opacity = 0.35});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final small = Paint()
      ..color = C.primary.withValues(alpha: 0.18)
      ..strokeWidth = 0.3;

    final big = Paint()
      ..color = C.primary.withValues(alpha: 0.14)
      ..strokeWidth = 0.7;

    for (double x = 0; x <= size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), small);
    }
    for (double y = 0; y <= size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), small);
    }
    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), big);
    }
    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), big);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}