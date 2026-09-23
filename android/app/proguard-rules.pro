# Flutter embedding: el motor invoca estas clases por reflexion.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# home_widget: el receiver y las clases del widget se referencian desde
# AndroidManifest.xml y desde el sistema de AppWidgets, hay que mantenerlas.
-keep class es.antonborri.home_widget.** { *; }
-keep class com.fuelfinder.fuel_finder.CheapestPriceWidgetProvider { *; }

# flutter_local_notifications: usa reflexion para (de)serializar las
# notificaciones programadas.
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Gson (usado internamente por algunos plugins) necesita conservar los
# nombres de campo para (de)serializar JSON con reflexion.
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# El motor de Flutter referencia las clases de "Play Core" (componentes
# diferidos / dynamic feature modules) aunque esta app no los use. Sin la
# dependencia real presente, R8 solo necesita saber que puede ignorarlas.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
