import 'package:flutter/material.dart';

import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../data/mock/mock_agenda.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

import '../atelier/widgets/ham_btn.dart';
import 'widgets/event_tile.dart';
import 'widgets/month_grid.dart';

class AgendaScreen extends StatefulWidget {
  final VoidCallback onMenu;
  const AgendaScreen({super.key, required this.onMenu});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime month; // 1er jour du mois affiché
  late DateTime selected; // jour sélectionné

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
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${names[m.month - 1]} ${m.year}';
  }

  void _prevMonth() => setState(() => month = DateTime(month.year, month.month - 1, 1));
  void _nextMonth() => setState(() => month = DateTime(month.year, month.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    // jours marqués (événements)
    final marked = agendaEvents.map((e) => _dayOnly(e.date)).toSet();

    // événements du jour sélectionné
    final todays = agendaEvents.where((e) => _dayOnly(e.date) == _dayOnly(selected)).toList();

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
                    Text('◷ AGENDA', style: StoryText.mono(size: 10, color: C.green, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text('Rituel d’écriture', style: StoryText.serif(size: 28, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Planifiez et suivez vos sessions',
                      style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic),
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
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: const Icon(Icons.chevron_left_rounded, color: C.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _monthLabel(month),
                        style: StoryText.mono(size: 12, color: C.text, letterSpacing: 2),
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
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: const Icon(Icons.chevron_right_rounded, color: C.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: C.green.withOpacity(0.12)),
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
                      style: StoryText.mono(size: 10, color: C.textDim, letterSpacing: 2),
                    ),
                    GestureDetector(
                      onTap: () => _openAddSheet(context),
                      child: Text('Ajouter →', style: StoryText.mono(size: 10, color: C.green)),
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
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Text(
                    'Aucun événement ce jour-là.',
                    style: StoryText.sans(size: 13, color: C.textDim, style: FontStyle.italic),
                  ),
                )
                    : Column(children: [for (final e in todays) EventTile(e: e)]),
              ),
            ],
          ),
        ),

        // FAB add
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
                gradient: LinearGradient(colors: [C.green, C.green.withOpacity(0.55)]),
                boxShadow: [
                  BoxShadow(color: C.green.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 6)),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: C.surface3, borderRadius: BorderRadius.circular(99)),
              ),
              const SizedBox(height: 14),
              Text('Ajouter (placeholder)', style: StoryText.serif(size: 18, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'On branchera une vraie création plus tard.',
                style: StoryText.sans(size: 13, color: C.textMuted, style: FontStyle.italic),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: C.green.withOpacity(0.18),
                    foregroundColor: C.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ajouter (à venir)')),
                    );
                  },
                  child: const Text('OK'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}