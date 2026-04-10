import 'package:cloud_firestore/cloud_firestore.dart';

/// Listens for admin "Send request to patient app" pushes (demo_billing/patient_push).
class BillingPushService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>?> patientPushStream() {
    return _db.collection('demo_billing').doc('patient_push').snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data();
    });
  }
}
