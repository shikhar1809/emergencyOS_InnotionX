import 'models/doctor_model.dart';

/// Fixed demo identity — no Firebase Auth; opens straight into the staff portal.
class DemoStaff {
  DemoStaff._();

  static const DoctorModel profile = DoctorModel(
    uid: 'demo-staff-portal',
    name: 'Demo Staff',
    email: 'staff.demo@goelhospital.com',
    role: 'Doctor',
    wardId: '',
    shiftId: '',
    onDuty: false,
    department: 'Emergency',
  );
}
