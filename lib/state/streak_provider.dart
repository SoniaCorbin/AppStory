import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class StreakState {
  final int currentStreak;
  final int totalActiveDays;

  const StreakState({
    required this.currentStreak,
    required this.totalActiveDays,
  });
}

final streakProvider =
StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier()
      : super(const StreakState(currentStreak: 0, totalActiveDays: 0)) {
    _load();
  }

  Box get _box => Hive.box('settings');

  static const _kLastActive = 'streak_last_active';
  static const _kCurrent    = 'streak_current';
  static const _kTotal      = 'streak_total';

  void _load() {
    final current = _box.get(_kCurrent, defaultValue: 0) as int;
    final total   = _box.get(_kTotal,   defaultValue: 0) as int;
    state = StreakState(currentStreak: current, totalActiveDays: total);
  }

  Future<void> recordActivity() async {
    final today = _todayKey();
    final lastActive = _box.get(_kLastActive) as String?;

    if (lastActive == today) return;

    final yesterday = _yesterdayKey();
    final current = _box.get(_kCurrent, defaultValue: 0) as int;
    final total   = _box.get(_kTotal,   defaultValue: 0) as int;

    final newStreak = (lastActive == yesterday) ? current + 1 : 1;
    final newTotal  = total + 1;

    await _box.put(_kLastActive, today);
    await _box.put(_kCurrent,    newStreak);
    await _box.put(_kTotal,      newTotal);

    state = StreakState(currentStreak: newStreak, totalActiveDays: newTotal);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayKey() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }
}
