import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';
import '../../../models/story.dart';
import '../../../widgets/chips/block_chip.dart';

class StoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onPressed;

  const StoryCard({super.key, required this.story, required this.onPressed});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.story;

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        transform: Matrix4.identity()..scale(pressed ? 0.98 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: s.color.withOpacity(0.13)),
          boxShadow: [
            if (!pressed)
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // accent top bar
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(colors: [s.color, Colors.transparent]),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: StoryText.serif(size: 16, weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(s.genre, style: StoryText.sans(size: 12, color: C.textMuted, style: FontStyle.italic)),
                        ],
                      ),
                    ),
                    Text(s.lastEdit, style: StoryText.mono(size: 10, color: C.textDim)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final b in s.blocks) BlockChip(type: b, mini: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          height: 3,
                          color: C.surface3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: s.progress / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [s.color, s.color.withOpacity(0.53)]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${s.progress}%', style: StoryText.mono(size: 10, color: s.color)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}