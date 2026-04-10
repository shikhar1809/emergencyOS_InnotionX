// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;

class WebStorage {
  static String? getSessionString(String key) => html.window.sessionStorage[key];

  static void setSessionString(String key, String value) {
    html.window.sessionStorage[key] = value;
  }

  static void removeSessionKey(String key) {
    html.window.sessionStorage.remove(key);
  }

  static Map<String, dynamic> getLocalJson(String key) {
    final raw = html.window.localStorage[key];
    if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static void setLocalJson(String key, Map<String, dynamic> value) {
    html.window.localStorage[key] = jsonEncode(value);
  }
}

