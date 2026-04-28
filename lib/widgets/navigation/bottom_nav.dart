import 'package:flutter/material.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../screens/shell/nav_items.dart';

class BottomNav extends StatelessWidget {
  final NavTab active;
  final ValueChanged<NavTab> onNav;

  const BottomNav({super.key, required this.active, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: C.bg.withOpacity(0.85),
            border: Border(top: BorderSide(color: C.primary.withOpacity(0.12))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: NavTab.values.map((t) {
              final isActive = t == active;
              return InkWell(
                onTap: () => onNav(t),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? C.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon, size: 22, color: isActive ? C.primary : C.textMuted),
                      const SizedBox(height: 2),
                      Text(
                        t.label,
                        style: StoryText.mono(
                          size: 10,
                          color: isActive ? C.primary : C.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive ? C.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}