class QuickNote {
  final String text;
  final String time;
  const QuickNote(this.text, this.time);
}

final quickNotes = <QuickNote>[
  QuickNote('Et si le détective était aussi le coupable ?', '9:42'),
  QuickNote('Ambiance : pluie fine, néons, saxophone lointain', 'hier'),
  QuickNote('Nom de personnage : Elara Voss', 'lun.'),
];