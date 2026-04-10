import '../storage/web_storage.dart';

class FleetStorageKeys {
  static const sessionEmail = 'fleet_operator_email';
  static const localOnDuty = 'fleet_on_duty';
  static const localAssignments = 'fleet_assignments';
}

class FleetStorage {
  static String? getSessionEmail() => WebStorage.getSessionString(FleetStorageKeys.sessionEmail);

  static void setSessionEmail(String email) =>
      WebStorage.setSessionString(FleetStorageKeys.sessionEmail, email);

  static void clearSessionEmail() => WebStorage.removeSessionKey(FleetStorageKeys.sessionEmail);

  static Map<String, bool> getOnDutyMap() {
    final json = WebStorage.getLocalJson(FleetStorageKeys.localOnDuty);
    final map = <String, bool>{};
    for (final e in json.entries) {
      if (e.value is bool) map[e.key] = e.value as bool;
      if (e.value is String) map[e.key] = (e.value as String).toLowerCase() == 'true';
    }
    return map;
  }

  static void setOnDuty(String email, bool onDuty) {
    final map = WebStorage.getLocalJson(FleetStorageKeys.localOnDuty);
    map[email] = onDuty;
    WebStorage.setLocalJson(FleetStorageKeys.localOnDuty, map);
  }

  static Map<String, dynamic> getAssignmentsMap() =>
      WebStorage.getLocalJson(FleetStorageKeys.localAssignments);

  static Map<String, dynamic>? getAssignmentFor(String email) {
    final all = getAssignmentsMap();
    final v = all[email];
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.cast<String, dynamic>();
    return null;
  }

  static void clearAssignmentFor(String email) {
    final all = getAssignmentsMap();
    all.remove(email);
    WebStorage.setLocalJson(FleetStorageKeys.localAssignments, all);
  }
}

