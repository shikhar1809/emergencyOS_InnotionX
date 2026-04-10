import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String wardId;
  final String shiftId;
  final bool onDuty;
  final String department;

  const DoctorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.wardId,
    required this.shiftId,
    required this.onDuty,
    required this.department,
  });

  factory DoctorModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Doctor',
      wardId: data['wardId'] ?? '',
      shiftId: data['shiftId'] ?? '',
      onDuty: data['onDuty'] ?? false,
      department: data['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'wardId': wardId,
        'shiftId': shiftId,
        'onDuty': onDuty,
        'department': department,
      };

  DoctorModel copyWith({
    String? name,
    String? role,
    String? wardId,
    String? shiftId,
    bool? onDuty,
    String? department,
  }) {
    return DoctorModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      wardId: wardId ?? this.wardId,
      shiftId: shiftId ?? this.shiftId,
      onDuty: onDuty ?? this.onDuty,
      department: department ?? this.department,
    );
  }
}
