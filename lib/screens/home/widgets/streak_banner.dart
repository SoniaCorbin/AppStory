import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';

class StreakBanner extends StatefulWidget {
  const StreakBanner({super.key});

  @override
  State<StreakBanner> createState() => _StreakBannerState();
}

class _StreakBannerState extends State<StreakBanner> with SingleTickerProviderStateMixin {
  bool pop = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => pop = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const radius = 14.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            C.secondary.withOpacity(0.10),
            const Color(0xFF7B2FF7).withOpacity(0.10),
          ],
        ),
        border: Border.all(color: C.secondary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: C.secondary.withOpacity(0.13),
              border: Border.all(color: C.secondary.withOpacity(0.35), width: 1.5),
            ),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      scale: pop ? 1.0 : 0.85,
                      child: Text('4', style: StoryText.mono(size: 26, color: C.secondary)),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('jours de suite', style: StoryText.sans(size: 13, weight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('· record: 12', style: StoryText.mono(size: 10, color: C.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: C.surface3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      width: pop ? MediaQuery.sizeOf(context).width * 0.22 : 0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFFD700)]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Prochain badge à 7 jours →', style: StoryText.mono(size: 10, color: C.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}