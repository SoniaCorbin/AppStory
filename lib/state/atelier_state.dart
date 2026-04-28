import 'package:flutter/foundation.dart';
import '../models/assembled_block.dart';

@immutable
class AtelierState {
  final List<AssembledBlock> assembled;
  final bool generating;
  final bool generated;
  final String story;
  final bool saved;

  const AtelierState({
    required this.assembled,
    required this.generating,
    required this.generated,
    required this.story,
    this.saved = false,
  });

  factory AtelierState.initial(List<AssembledBlock> initialBlocks) => AtelierState(
    assembled: initialBlocks,
    generating: false,
    generated: false,
    story: '',
    saved: false,
  );

  AtelierState copyWith({
    List<AssembledBlock>? assembled,
    bool? generating,
    bool? generated,
    String? story,
    bool? saved,
  }) {
    return AtelierState(
      assembled: assembled ?? this.assembled,
      generating: generating ?? this.generating,
      generated: generated ?? this.generated,
      story: story ?? this.story,
      saved: saved ?? this.saved,
    );
  }
}