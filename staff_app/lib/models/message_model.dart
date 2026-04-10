import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String channel;
  final String senderUid;
  final String senderName;
  final String role;
  final String text;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.channel,
    required this.senderUid,
    required this.senderName,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      channel: data['channel'] ?? '',
      senderUid: data['senderUid'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      role: data['role'] ?? 'Staff',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'channel': channel,
        'senderUid': senderUid,
        'senderName': senderName,
        'role': role,
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}

class HazardModel {
  final String id;
  final String reportedBy;
  final String reportedByName;
  final String wardId;
  final String wardName;
  final String description;
  final DateTime timestamp;
  final bool resolved;

  const HazardModel({
    required this.id,
    required this.reportedBy,
    required this.reportedByName,
    required this.wardId,
    required this.wardName,
    required this.description,
    required this.timestamp,
    required this.resolved,
  });

  factory HazardModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HazardModel(
      id: doc.id,
      reportedBy: data['reportedBy'] ?? '',
      reportedByName: data['reportedByName'] ?? '',
      wardId: data['wardId'] ?? '',
      wardName: data['wardName'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolved: data['resolved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'reportedBy': reportedBy,
        'reportedByName': reportedByName,
        'wardId': wardId,
        'wardName': wardName,
        'description': description,
        'timestamp': Timestamp.fromDate(timestamp),
        'resolved': resolved,
      };
}
