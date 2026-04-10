import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientUid;
  final String patientNameSnapshot;
  final String serviceId;
  final String department;
  final String doctorUid;
  final String doctorNameSnapshot;
  final String status; // requested|scheduled|checked_in|completed|cancelled
  final DateTime createdAt;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String receptionQrToken;

  const AppointmentModel({
    required this.id,
    required this.patientUid,
    required this.patientNameSnapshot,
    required this.serviceId,
    required this.department,
    required this.doctorUid,
    required this.doctorNameSnapshot,
    required this.status,
    required this.createdAt,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.receptionQrToken,
  });

  factory AppointmentModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final startTs = data['scheduledStart'] as Timestamp?;
    final endTs = data['scheduledEnd'] as Timestamp?;
    final now = DateTime.now();
    return AppointmentModel(
      id: doc.id,
      patientUid: (data['patientUid'] ?? '') as String,
      patientNameSnapshot: (data['patientNameSnapshot'] ?? '') as String,
      serviceId: (data['serviceId'] ?? '') as String,
      department: (data['department'] ?? '') as String,
      doctorUid: (data['doctorUid'] ?? '') as String,
      doctorNameSnapshot: (data['doctorNameSnapshot'] ?? '') as String,
      status: (data['status'] ?? 'requested') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? now,
      scheduledStart: startTs?.toDate() ?? now,
      scheduledEnd: endTs?.toDate() ?? now.add(const Duration(minutes: 15)),
      receptionQrToken: (data['receptionQrToken'] ?? '') as String,
    );
  }

  bool get isPendingApproval => status == 'pending_approval';

  bool get canShowQr =>
      receptionQrToken.isNotEmpty &&
      (status == 'scheduled' || status == 'checked_in');

  Map<String, dynamic> toMap() => {
        'patientUid': patientUid,
        'patientNameSnapshot': patientNameSnapshot,
        'serviceId': serviceId,
        'department': department,
        'doctorUid': doctorUid,
        'doctorNameSnapshot': doctorNameSnapshot,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'scheduledStart': Timestamp.fromDate(scheduledStart),
        'scheduledEnd': Timestamp.fromDate(scheduledEnd),
        'receptionQrToken': receptionQrToken,
      };
}

