import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/agenda_event.dart';
import '../../state/agenda_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

import '../atelier/widgets/ham_btn.dart';
import 'widgets/event_tile.dart';
import 'widgets/month_grid.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  final VoidCallback onMenu;
  const AgendaScreen({super.key, required this.onMenu});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  late DateTime month;
  late DateTime selected;

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthOnly(DateTime d) => DateTime(d.year, d.month, 1);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    month = _monthOnly(now);
    selected = _dayOnly(now);
  }

  String _monthLabel(DateTime m) {
    const names = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${names[m.month - 1]} ${m.year}';
  }

  void _prevMonth() =>
      setState(() => month = DateTime(month.year, month.month - 1, 1));
  void _nextMonth() =>
      setState(() => month = DateTime(month.year, month.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(agendaProvider);

    final marked = allEvents.map((e) => _dayOnly(e.date)).toSet();
    final todays =
        allEvents.where((e) => _dayOnly(e.date) == _dayOnly(selected)).toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: false),
        Positioned.fill(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HamBtn(onMenu: widget.onMenu),
                    Text('◷ AGENDA',
                        style: StoryText.mono(
                            size: 10, color: C.green, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text('Rituel d\'écriture',
                        style:
                            StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Planifiez et suivez vos sessions',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textMuted,
                          style: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // Month header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _prevMonth,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Icon(Icons.chevron_left_rounded,
                            color: C.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _monthLabel(month),
                        style: StoryText.mono(
                            size: 12, color: C.text, letterSpacing: 2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _nextMonth,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Icon(Icons.chevron_right_rounded,
                            color: C.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: C.green.withValues(alpha: 0.12)),
                  ),
                  child: MonthGrid(
                    month: month,
                    selected: selected,
                    markedDays: marked,
                    onSelect: (d) => setState(() => selected = _dayOnly(d)),
                  ),
                ),
              ),

              // Day agenda
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SÉANCE · ${selected.day}/${selected.month}',
                      style: StoryText.mono(
                          size: 10, color: C.textDim, letterSpacing: 2),
                    ),
                    GestureDetector(
                      onTap: () => _openAddSheet(context),
                      child: Text('Ajouter →',
                          style: StoryText.mono(size: 10, color: C.green)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: todays.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Text(
                          'Aucun événement ce jour-là.',
                          style: StoryText.sans(
                              size: 13,
                              color: C.textDim,
                              style: FontStyle.italic),
                        ),
                      )
                    : Column(children: [
                        for (final e in todays)
                          Dismissible(
                            key: ValueKey('event_${e.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                  right: 24, bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4466)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFFF4466)),
                            ),
                            onDismissed: (_) => ref
                                .read(agendaProvider.notifier)
                                .deleteEvent(e.id),
                            child: GestureDetector(
                              onLongPress: () => ref
                                  .read(agendaProvider.notifier)
                                  .toggleComplete(e.id),
                              child: EventTile(e: e),
                            ),
                          ),
                      ]),
              ),
            ],
          ),
        ),

        // FAB
        Positioned(
          right: 24,
          bottom: 96,
          child: GestureDetector(
            onTap: () => _openAddSheet(context),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [C.green, C.green.withValues(alpha: 0.55)]),
                boxShadow: [
                  BoxShadow(
                      color: C.green.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    DateTime selectedDate = selected;
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedColor = '🟣';

    final colors = const ['🟣', '🟠', '🟡', '🟢', '🔵', '🔴'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: C.surface3,
                            borderRadius: BorderRadius.circular(99)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Nouvel événement',
                        style: StoryText.serif(
                            size: 20, weight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    Text('TITRE',
                        style: StoryText.mono(
                            size: 10,
                            color: C.textDim,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Écrire 500 mots, relire chapitre 2…',
                        filled: true,
                        fillColor: C.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setSheetState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: C.surface2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 16, color: C.textMuted),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: StoryText.sans(
                                        size: 13, color: C.text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setSheetState(() => selectedTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: C.surface2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 16, color: C.textMuted),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                    style: StoryText.sans(
                                        size: 13, color: C.text),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text('COULEUR',
                        style: StoryText.mono(
                            size: 10,
                            color: C.textDim,
                            letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (final c in colors)
                          GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedColor = c),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selectedColor == c
                                    ? C.green.withValues(alpha: 0.20)
                                    : C.surface2,
                                border: Border.all(
                                  color: selectedColor == c
                                      ? C.green
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(c,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;
                          ref.read(agendaProvider.notifier).addEvent(
                                date: selectedDate,
                                title: title,
                                time:
                                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                color: selectedColor,
                              );
                          setState(() => selected = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day));
                          Navigator.pop(ctx);
                        },
                        child: const Text('Ajouter'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
