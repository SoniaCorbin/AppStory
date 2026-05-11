import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';
import '../../../models/assembled_block.dart';
import '../../../models/block_type.dart';
import '../../../widgets/chips/block_chip.dart';

class AssembledBlockTile extends StatelessWidget {
  final AssembledBlock block;
  final VoidCallback onRemove;
  final ValueChanged<String> onValueChanged;

  const AssembledBlockTile({
    super.key,
    required this.block,
    required this.onRemove,
    required this.onValueChanged,
  });

  bool get _isPlaceholder => block.value.contains('(appuyer');

  Future<void> _openEditor(BuildContext context) async {
    final ctrl = TextEditingController(
      text: _isPlaceholder ? '' : block.value,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: C.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Text(block.type.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                block.type.label,
                style: StoryText.serif(size: 18, weight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.type.desc,
                style: StoryText.sans(
                    size: 12,
                    color: C.textMuted,
                    style: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                style: StoryText.sans(size: 14),
                decoration: InputDecoration(
                  hintText: 'Écris ton ${block.type.label.toLowerCase()}…',
                  hintStyle: StoryText.sans(size: 13, color: C.textDim),
                  filled: true,
                  fillColor: C.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: StoryText.sans(size: 13, color: C.textMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: block.type.color,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      onValueChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bt = block.type;
    final italic = _isPlaceholder;

    final baseStyle = StoryText.sans(
      size: 13,
      color: C.text,
      style: italic ? FontStyle.italic : FontStyle.normal,
    );

    final textStyle = italic
        ? baseStyle.copyWith(color: baseStyle.color?.withValues(alpha: 0.55))
        : baseStyle;

    return GestureDetector(
      onTap: () => _openEditor(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
            const SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 14, color: C.textDim),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child:
                    Text('×', style: StoryText.sans(size: 18, color: C.textDim)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
