import 'package:flutter/foundation.dart';
import '../models/assembled_block.dart';

@immutable
class AtelierState {
  final List<AssembledBlock> assembled;
  final bool generating;
  final bool generated;
  final String story;

  const AtelierState({
    required this.assembled,
    required this.generating,
    required this.generated,
    required this.story,
  });

  factory AtelierState.initial(List<AssembledBlock> initialBlocks) => AtelierState(
    assembled: initialBlocks,
    generating: false,
    generated: false,
    story: '',
  );

  AtelierState copyWith({
    List<AssembledBlock>? assembled,
    bool? generating,
    bool? generated,
    String? story,
  }) {
    return AtelierState(
      assembled: assembled ?? this.assembled,
      generating: generating ?? this.generating,
      generated: generated ?? this.generated,
      story: story ?? this.story,
    );
  }
}