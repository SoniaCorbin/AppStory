import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';
import '../../../models/assembled_block.dart';
import '../../../models/block_type.dart';
import '../../../widgets/chips/block_chip.dart';

class AssembledBlockTile extends StatelessWidget {
  final AssembledBlock block;
  final VoidCallback onRemove;

  const AssembledBlockTile({
    super.key,
    required this.block,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bt = block.type;
    final italic = block.value.contains('(');

    final baseStyle = StoryText.sans(
      size: 13,
      color: C.text,
      style: italic ? FontStyle.italic : FontStyle.normal,
    );

    final textStyle = italic
        ? baseStyle.copyWith(color: baseStyle.color?.withValues(alpha: 0.55))
        : baseStyle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bt.color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          BlockChip(type: bt, mini: true),
          const SizedBox(width: 12),
          Expanded(child: Text(block.value, style: textStyle)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('×', style: StoryText.sans(size: 18, color: C.textDim)),
            ),
          ),
        ],
      ),
    );
  }
}