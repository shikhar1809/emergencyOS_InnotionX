import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_model.dart';

class DemoSession {
  static const _kEnabled = 'demo_enabled';

  static final ValueNotifier<bool> activeNotifier = ValueNotifier<bool>(false);

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<void> hydrate() async {
    activeNotifier.value = await isEnabled();
  }

  static Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    activeNotifier.value = true;
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    activeNotifier.value = false;
  }

  static PatientModel demoPatient() {
    return const PatientModel(
      uid: 'demo_patient1',
      name: 'Demo Patient',
      email: 'patient1@goelhospital.com',
      phone: '+91 90000 00001',
    );
  }
}

