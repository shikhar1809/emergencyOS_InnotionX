import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Creates a **pending** request (no doctor, no QR). Admin approves in Operations
  /// and assigns staff; patient listens until `status` becomes `scheduled`.
  Future<AppointmentModel> createAppointment({
    required PatientModel patient,
    required String serviceId,
    required String department,
    required String symptoms,
  }) async {
    final ref = await _db.collection('appointments').add({
      'patientUid': patient.uid,
      'patientNameSnapshot': patient.name,
      'patientPhone': patient.phone,
      'serviceId': serviceId,
      'department': department,
      'symptoms': symptoms,
      'doctorUid': '',
      'doctorNameSnapshot': '',
      'status': 'pending_approval',
      'createdAt': FieldValue.serverTimestamp(),
      'receptionQrToken': '',
    });

    final created = await ref.get();
    return AppointmentModel.fromDoc(created);
  }

  Stream<AppointmentModel?> latestAppointmentForPatient(String patientUid) {
    return _db
        .collection('appointments')
        .where('patientUid', isEqualTo: patientUid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return AppointmentModel.fromDoc(snap.docs.first);
    });
  }
}

