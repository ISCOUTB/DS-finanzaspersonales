# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }

# Mantén las clases y métodos de las bibliotecas de terceros necesarias
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Evita la eliminación de clases y métodos usados por reflexión
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod