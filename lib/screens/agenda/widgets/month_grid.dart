import 'package:flutter/material.dart';
import '../../../core/constants/story_tokens.dart';
import '../../../core/theme/story_text_styles.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month; // ex: 2026-04-01
  final DateTime selected;
  final Set<DateTime> markedDays; // jours avec événements (date normalisée)
  final ValueChanged<DateTime> onSelect;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.markedDays,
    required this.onSelect,
  });

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = first.weekday; // 1=Mon..7=Sun
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // On veut une grille 7 colonnes. On met lundi en premier.
    final leading = firstWeekday - 1; // 0..6
    final totalCells = 42; // 6 semaines * 7 jours

    const week = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final w in week)
              Expanded(
                child: Center(
                  child: Text(w, style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 1.3)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final dayNum = index - leading + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox.shrink();
            }

            final date = DateTime(month.year, month.month, dayNum);
            final isSelected = _dayOnly(date) == _dayOnly(selected);
            final isMarked = markedDays.contains(_dayOnly(date));

            return GestureDetector(
              onTap: () => onSelect(date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? C.primary.withOpacity(0.18) : C.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? C.primary.withOpacity(0.50)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '$dayNum',
                        style: StoryText.mono(
                          size: 12,
                          color: isSelected ? C.primary : C.text,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isMarked)
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 3,
                            decoration: BoxDecoration(
                              color: isSelected ? C.primary : C.accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}