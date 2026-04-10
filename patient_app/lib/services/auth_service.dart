import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_model.dart';

/// Local demo auth only (no Firebase Auth). Firestore may still be used for appointments.
class PatientAuthService {
  static const demoEmail = 'patient.demo@goelhospital.com';
  static const demoPassword = 'PatientDemo123';

  static const PatientModel demoProfile = PatientModel(
    uid: 'demo-patient-lko',
    name: 'Anjali Patel (Demo)',
    email: demoEmail,
    phone: '+91 98765 43210',
  );

  static const _prefsKey = 'eos_patient_demo_session';

  Future<PatientModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PatientModel.fromSessionJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Returns [demoProfile] when email/password match demo credentials; otherwise null.
  Future<PatientModel?> signIn(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (e != demoEmail.toLowerCase() || password != demoPassword) {
      return null;
    }
    await _persist(demoProfile);
    return demoProfile;
  }

  Future<void> _persist(PatientModel patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(patient.toSessionJson()));
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// Opens the portal directly as the demo patient (no login UI).
  Future<PatientModel> openDemoSession() async {
    await _persist(demoProfile);
    return demoProfile;
  }
}
