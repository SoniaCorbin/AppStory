import 'package:flutter/material.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/block_type.dart';

class BlockChip extends StatelessWidget {
  final BlockType type;
  final String? labelOverride;
  final bool mini;
  final VoidCallback? onPressed;
  final bool selected;

  const BlockChip({
    super.key,
    required this.type,
    this.labelOverride,
    this.mini = false,
    this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = type.color;
    final bg = selected ? c.withValues(alpha: 0.20) : c.withValues(alpha: 0.10);
    final border = selected ? c.withValues(alpha: 0.55) : c.withValues(alpha: 0.20);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.diagonal3Values(
          selected ? 1.04 : 1.0,
          selected ? 1.04 : 1.0,
          1.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: mini ? 10 : 14,
          vertical: mini ? 4 : 7,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type.icon, style: TextStyle(fontSize: mini ? 11 : 13)),
            const SizedBox(width: 6),
            Text(
              labelOverride ?? type.label,
              style: StoryText.mono(
                size: mini ? 11 : 13,
                color: c,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}