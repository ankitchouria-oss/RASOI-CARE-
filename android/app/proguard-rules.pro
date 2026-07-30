# ProGuard rules for Play Core / deferred components used by Flutter
# Keep Play Core classes used by Flutter deferred components / SplitCompat
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# If R8 generated missing_rules.txt, merge those rules here.
