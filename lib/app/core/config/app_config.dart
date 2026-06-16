class AppConfig {
  static const currentVersion = '1.0.0';
  static const bool https = true;
  static const String publicFolder = "public";
  static const String protocol = https ? "https://" : "http://";
  static const String rawBaseUrl = "$protocol$domainPath";
  static const String basePath = "$rawBaseUrl/$apiEndPath";
  static const domainPath = "wa.acibd.com/";
  static const String apiEndPath = "api/protable_attendance_system/api/";

  static const uploadImageBasePath = basePath;
  static const releaseDate = '20260506';

}
