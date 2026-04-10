import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String uid;
  final String name;
  final String email;
  final String phone;

  const PatientModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PatientModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PatientModel(
      uid: doc.id,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
      };

  Map<String, dynamic> toSessionJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
      };

  factory PatientModel.fromSessionJson(Map<String, dynamic> json) {
    return PatientModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

