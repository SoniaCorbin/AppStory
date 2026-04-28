import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';
import '../../../models/coffre_item.dart';

class CoffreCard extends StatefulWidget {
  final CoffreItem item;
  final VoidCallback? onPressed;

  const CoffreCard({super.key, required this.item, this.onPressed});

  @override
  State<CoffreCard> createState() => _CoffreCardState();
}

class _CoffreCardState extends State<CoffreCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.diagonal3Values(
          pressed ? 0.985 : 1.0,
          pressed ? 0.985 : 1.0,
          1.0,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: item.color.withValues(alpha: 0.20)),
              ),
              child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StoryText.sans(size: 14, weight: FontWeight.w500, color: C.text),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in item.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(t, style: StoryText.mono(size: 10, color: item.color)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(item.date, style: StoryText.mono(size: 10, color: C.textDim)),
          ],
        ),
      ),
    );
  }
}