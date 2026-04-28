import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';

class HamBtn extends StatelessWidget {
  final VoidCallback onMenu;
  const HamBtn({super.key, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    Widget bar() => Container(
      width: 18,
      height: 2,
      decoration: BoxDecoration(
        color: C.primary,
        borderRadius: BorderRadius.circular(1),
      ),
    );

    return GestureDetector(
      onTap: onMenu,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                bar(),
                const SizedBox(height: 4),
                bar(),
                const SizedBox(height: 4),
                bar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}