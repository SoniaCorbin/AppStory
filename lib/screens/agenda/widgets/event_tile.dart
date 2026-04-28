import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';
import '../../../models/agenda_event.dart';

class EventTile extends StatelessWidget {
  final AgendaEvent e;
  const EventTile({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(e.color, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: StoryText.sans(
                    size: 14,
                    weight: FontWeight.w600,
                    color: e.completed ? C.textDim : C.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(e.time, style: StoryText.mono(size: 10, color: C.textDim)),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: e.completed ? C.green.withValues(alpha: 0.18) : C.surface2,
              border: Border.all(color: e.completed ? C.green.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.10)),
            ),
            child: e.completed
                ? const Center(child: Text('✓', style: TextStyle(color: C.green, fontSize: 12)))
                : null,
          ),
        ],
      ),
    );
  }
}