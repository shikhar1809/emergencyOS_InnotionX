import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/shift_model.dart';
import '../models/message_model.dart';
import '../models/presence_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Doctor / User ──────────────────────────────────────────────────────────

  Stream<DoctorModel> doctorStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => DoctorModel.fromDoc(doc),
        );
  }

  Future<void> setDutyStatus(String uid, bool onDuty) {
    return _db.collection('users').doc(uid).update({'onDuty': onDuty});
  }

  // ── Shifts ─────────────────────────────────────────────────────────────────

  Stream<List<ShiftModel>> shiftsForUser(String uid) {
    return _db
        .collection('shifts')
        .where('assignedUids', arrayContains: uid)
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs.map(ShiftModel.fromDoc).toList());
  }

  // ── Wards ──────────────────────────────────────────────────────────────────

  Stream<WardModel?> wardStream(String wardId) {
    if (wardId.isEmpty) return Stream.value(null);
    return _db
        .collection('wards')
        .doc(wardId)
        .snapshots()
        .map((doc) => doc.exists ? WardModel.fromDoc(doc) : null);
  }

  Stream<List<WardModel>> allWardsStream() {
    return _db
        .collection('wards')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(WardModel.fromDoc).toList());
  }

  // ── Internal Comms ─────────────────────────────────────────────────────────

  Stream<List<MessageModel>> messagesStream(String channel) {
    return _db
        .collection('comms')
        .doc(channel)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limitToLast(80)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromDoc).toList());
  }

  Future<void> sendMessage({
    required String channel,
    required String senderUid,
    required String senderName,
    required String role,
    required String text,
  }) {
    final msg = MessageModel(
      id: '',
      channel: channel,
      senderUid: senderUid,
      senderName: senderName,
      role: role,
      text: text,
      timestamp: DateTime.now(),
    );
    return _db
        .collection('comms')
        .doc(channel)
        .collection('messages')
        .add(msg.toMap());
  }

  // ── Presence (Online Staff) ────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _presenceRef(String uid) =>
      _db.collection('presence').doc(uid);

  Stream<List<PresenceModel>> onlinePresenceStream() {
    return _db
        .collection('presence')
        .where('online', isEqualTo: true)
        .orderBy('role')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(PresenceModel.fromDoc).toList());
  }

  Future<void> setPresenceOnline({
    required DoctorModel doctor,
    String state = 'online',
  }) {
    return _presenceRef(doctor.uid).set(
      {
        'name': doctor.name,
        'role': doctor.role,
        'department': doctor.department,
        'online': true,
        'state': state,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> heartbeatPresence({
    required DoctorModel doctor,
    String state = 'online',
  }) {
    // Keep online true; update lastSeen so web can treat this as fresh presence.
    return _presenceRef(doctor.uid).set(
      {
        'name': doctor.name,
        'role': doctor.role,
        'department': doctor.department,
        'online': true,
        'state': state,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setPresenceOffline({
    required DoctorModel doctor,
  }) {
    return _presenceRef(doctor.uid).set(
      {
        'name': doctor.name,
        'role': doctor.role,
        'department': doctor.department,
        'online': false,
        'state': 'offline',
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ── Hazards ────────────────────────────────────────────────────────────────

  Future<void> raiseHazard({
    required String reportedBy,
    required String reportedByName,
    required String wardId,
    required String wardName,
    required String description,
  }) async {
    final hazard = HazardModel(
      id: '',
      reportedBy: reportedBy,
      reportedByName: reportedByName,
      wardId: wardId,
      wardName: wardName,
      description: description,
      timestamp: DateTime.now(),
      resolved: false,
    );
    await _db.collection('hazards').add(hazard.toMap());

    // Also post a message to the #alerts channel so admin sees it immediately
    await sendMessage(
      channel: 'alerts',
      senderUid: reportedBy,
      senderName: reportedByName,
      role: 'HAZARD ALERT',
      text: '🚨 HAZARD raised in $wardName: $description',
    );
  }

  Stream<List<HazardModel>> activeHazardsStream() {
    return _db
        .collection('hazards')
        .where('resolved', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(HazardModel.fromDoc).toList());
  }
}
