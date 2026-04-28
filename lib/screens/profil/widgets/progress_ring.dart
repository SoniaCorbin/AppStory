import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final String label;
  final String value;
  final Color color;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(progress: progress, color: color),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: StoryText.mono(size: 22, color: color, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(label, style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    final track = Paint()
    ..color = C.surface3
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

    final arc = Paint()
    ..shader = LinearGradient(
      colors: [color, color.withValues(alpha: 0.4)],
    ).createShader(Rect.fromCircle(center: center, radius: radius))
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final start = -math.pi / 2;
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}