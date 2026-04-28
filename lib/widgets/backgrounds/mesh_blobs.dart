import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';

class MeshBlobs extends StatelessWidget {
  final bool warm;
  const MeshBlobs({super.key, this.warm = false});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final blobs = warm
        ? [
      _Blob(C.secondary, const Offset(0.10, 0.05), const Size(160, 140)),
      _Blob(C.accent, const Offset(0.55, 0.40), const Size(180, 160)),
      _Blob(C.primary, const Offset(0.20, 0.65), const Size(120, 120)),
    ]
        : [
      _Blob(C.primary, const Offset(0.05, 0.00), const Size(180, 160)),
      _Blob(C.accent, const Offset(0.50, 0.30), const Size(200, 180)),
      _Blob(C.secondary, const Offset(0.15, 0.60), const Size(140, 140)),
    ];

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final b in blobs)
              Positioned(
                left: size.width * b.pos.dx,
                top: size.height * b.pos.dy,
                width: b.size.width,
                height: b.size.height,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: b.color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Blob {
  final Color color;
  final Offset pos;
  final Size size;
  _Blob(this.color, this.pos, this.size);
}