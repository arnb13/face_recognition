# Keep Google ML Kit (bundled face-detection model) — R8 otherwise strips/
# obfuscates classes the native bridge reflects on, causing a NullPointerException
# in face detection on release builds.
-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**

# Keep TensorFlow Lite (MobileFaceNet embedding + anti-spoof models).
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
