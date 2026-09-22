import 'package:flutter/foundation.dart';
import 'dart:io';

class RootDetectionService {
  /// Retourne true si le device semble rooté.
  static bool get isRooted {
    if (kDebugMode) return false; // pas de blocage en dev
    if (!Platform.isAndroid) return false;

    // Fichiers communs sur devices rootés
    const suspiciousPaths = [
      '/system/app/Superuser.apk',
      '/system/xbin/su',
      '/system/bin/su',
      '/sbin/su',
      '/su/bin/su',
      '/data/local/su',
      '/data/local/bin/su',
      '/data/local/xbin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/dev/com.koushikdutta.superuser.daemon/',
      '/system/app/SuperSU.apk',
    ];

    for (final path in suspiciousPaths) {
      if (File(path).existsSync()) return true;
    }

    return false;
  }
}