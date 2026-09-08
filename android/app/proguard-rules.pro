# ---------- Flutter ----------
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ---------- Hive ----------
-keep class com.hivedb.** { *; }

# ---------- flutter_secure_storage ----------
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ---------- Kotlin / Coroutines ----------
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# ---------- Sécurité générale ----------
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*