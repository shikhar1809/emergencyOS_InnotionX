import 'package:shared_preferences/shared_preferences.dart';

import '../models/doctor_model.dart';

class DemoSession {
  static const _kEnabled = 'demo_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kEnabled) ?? false;
  }

  static Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
  }

  static DoctorModel demoDoctor() {
    return const DoctorModel(
      uid: 'demo_doctor3',
      name: 'Demo Doctor (doctor3)',
      email: 'doctor3@goelhospital.com',
      role: 'Doctor',
      wardId: 'ER',
      shiftId: 'DEMO',
      onDuty: true,
      department: 'Emergency',
    );
  }
}

