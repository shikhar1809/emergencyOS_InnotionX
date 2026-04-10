import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  final String id;
  final String label;
  final DateTime startTime;
  final DateTime endTime;
  final String wardId;
  final String wardName;
  final List<String> assignedUids;

  const ShiftModel({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.wardId,
    required this.wardName,
    required this.assignedUids,
  });

  factory ShiftModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShiftModel(
      id: doc.id,
      label: data['label'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 8)),
      wardId: data['wardId'] ?? '',
      wardName: data['wardName'] ?? '',
      assignedUids: List<String>.from(data['assignedUids'] ?? []),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  String get durationLabel {
    final h = endTime.difference(startTime).inHours;
    return '${h}h shift';
  }
}

class WardModel {
  final String id;
  final String name;
  final String floor;
  final int totalBeds;
  final int occupiedBeds;

  const WardModel({
    required this.id,
    required this.name,
    required this.floor,
    required this.totalBeds,
    required this.occupiedBeds,
  });

  factory WardModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WardModel(
      id: doc.id,
      name: data['name'] ?? '',
      floor: data['floor'] ?? '',
      totalBeds: data['totalBeds'] ?? 0,
      occupiedBeds: data['occupiedBeds'] ?? 0,
    );
  }

  int get freeBeds => totalBeds - occupiedBeds;
  double get occupancyRate => totalBeds > 0 ? occupiedBeds / totalBeds : 0.0;
}
