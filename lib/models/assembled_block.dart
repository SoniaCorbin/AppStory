import 'package:flutter/foundation.dart';
import 'block_type.dart';

@immutable
class AssembledBlock {
  final BlockType type;
  final String value;

  const AssembledBlock({
    required this.type,
    required this.value,
});

  AssembledBlock copyWith({BlockType? type, String? value}) {
    return AssembledBlock(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }
}
