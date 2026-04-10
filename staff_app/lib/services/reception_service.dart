import 'package:cloud_firestore/cloud_firestore.dart';

class ReceptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Scan/check-in flow:
  /// - Find appointment by receptionQrToken
  /// - Mark appointment checked_in
  /// - Create an alert for the assigned doctor
  Future<void> checkInByReceptionToken({
    required String receptionQrToken,
    required String scannedByUid,
    required String scannedByName,
  }) async {
    final token = receptionQrToken.trim();
    if (token.isEmpty) {
      throw ArgumentError('Empty QR token');
    }

    final apptSnap = await _db
        .collection('appointments')
        .where('receptionQrToken', isEqualTo: token)
        .limit(1)
        .get();

    if (apptSnap.docs.isEmpty) {
      throw StateError('No appointment found for this QR');
    }

    final apptDoc = apptSnap.docs.first;
    final apptRef = apptDoc.reference;
    final data = apptDoc.data();

    final doctorUid = (data['doctorUid'] ?? '').toString();
    final patientUid = (data['patientUid'] ?? '').toString();
    final patientName = (data['patientNameSnapshot'] ?? 'Patient').toString();

    if (doctorUid.isEmpty) {
      throw StateError('Appointment has no assigned doctor');
    }

    await _db.runTransaction((tx) async {
      tx.update(apptRef, {
        'status': 'checked_in',
        'checkedInAt': FieldValue.serverTimestamp(),
        'checkedInByUid': scannedByUid,
        'checkedInByName': scannedByName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final alertRef = _db
          .collection('doctor_alerts')
          .doc(doctorUid)
          .collection('alerts')
          .doc();
      tx.set(alertRef, {
        'type': 'checkin',
        'appointmentId': apptDoc.id,
        'patientUid': patientUid,
        'patientNameSnapshot': patientName,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

