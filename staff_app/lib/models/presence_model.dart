import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceModel {
  final String uid;
  final String name;
  final String role;
  final String department;
  final bool online;
  final String state; // online | idle | offline
  final DateTime lastSeen;

  const PresenceModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.department,
    required this.online,
    required this.state,
    required this.lastSeen,
  });

  factory PresenceModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PresenceModel(
      uid: doc.id,
      name: (data['name'] ?? '') as String,
      role: (data['role'] ?? 'Staff') as String,
      department: (data['department'] ?? '') as String,
      online: (data['online'] ?? false) as bool,
      state: (data['state'] ?? 'offline') as String,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'department': department,
        'online': online,
        'state': state,
        'lastSeen': Timestamp.fromDate(lastSeen),
      };
}

