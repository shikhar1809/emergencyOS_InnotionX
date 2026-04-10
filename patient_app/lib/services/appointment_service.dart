import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment_model.dart';
import '../models/patient_model.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _randomToken({int bytes = 18}) {
    final r = Random.secure();
    final data = List<int>.generate(bytes, (_) => r.nextInt(256));
    return base64Url.encode(data).replaceAll('=', '');
  }

  /// Minimal “availability” implementation:
  /// - Find first on-duty doctor in `users` matching department (optional).
  /// - Create an appointment + QR token.
  ///
  /// This is intentionally simple; can be upgraded to Functions+Gemini later.
  Future<AppointmentModel> createAppointment({
    required PatientModel patient,
    required String serviceId,
    required String department,
    required String symptoms,
  }) async {
    Query base = _db.collection('users').where('role', isEqualTo: 'Doctor').where('onDuty', isEqualTo: true);
    Query query = base;
    final dept = department.trim();
    if (dept.isNotEmpty) query = query.where('department', isEqualTo: dept);

    QuerySnapshot snap = await query.limit(1).get();
    if (snap.docs.isEmpty) {
      // Fallback: if department filtering is too strict (common when doctor profile department is blank),
      // still allow a slot by routing to any on-duty doctor.
      snap = await base.limit(1).get();
    }
    if (snap.docs.isEmpty) {
      throw StateError(dept.isEmpty ? 'No on-duty doctor available' : 'No on-duty doctor available for $dept');
    }

    final doctorDoc = snap.docs.first;
    final doctorUid = doctorDoc.id;
    final doctorName = (doctorDoc.data() as Map<String, dynamic>)['name']?.toString() ?? 'Doctor';

    final now = DateTime.now();
    final start = now.add(const Duration(minutes: 30));
    final end = start.add(const Duration(minutes: 15));
    final token = _randomToken();

    final ref = await _db.collection('appointments').add({
      'patientUid': patient.uid,
      'patientNameSnapshot': patient.name,
      'serviceId': serviceId,
      'department': department,
      'symptoms': symptoms,
      'doctorUid': doctorUid,
      'doctorNameSnapshot': doctorName,
      'status': 'scheduled',
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledStart': Timestamp.fromDate(start),
      'scheduledEnd': Timestamp.fromDate(end),
      'receptionQrToken': token,
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

