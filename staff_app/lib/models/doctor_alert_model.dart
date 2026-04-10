import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAlertModel {
  final String id;
  final String type; // checkin|new_appointment
  final String appointmentId;
  final String patientUid;
  final String patientNameSnapshot;
  final bool read;
  final DateTime createdAt;

  const DoctorAlertModel({
    required this.id,
    required this.type,
    required this.appointmentId,
    required this.patientUid,
    required this.patientNameSnapshot,
    required this.read,
    required this.createdAt,
  });

  factory DoctorAlertModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return DoctorAlertModel(
      id: doc.id,
      type: (data['type'] ?? 'checkin') as String,
      appointmentId: (data['appointmentId'] ?? '') as String,
      patientUid: (data['patientUid'] ?? '') as String,
      patientNameSnapshot: (data['patientNameSnapshot'] ?? '') as String,
      read: (data['read'] ?? false) as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

