# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core (deferred components — not used but referenced by Flutter engine)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Shared Preferences
-keep class androidx.datastore.** { *; }

# Keep app models
-keep class com.cakhia.ca_khia_fc.** { *; }
