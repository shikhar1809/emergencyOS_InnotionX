import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/doctor_alert_model.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class AlertsOnlyScreen extends StatefulWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const AlertsOnlyScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  State<AlertsOnlyScreen> createState() => _AlertsOnlyScreenState();
}

class _AlertsOnlyScreenState extends State<AlertsOnlyScreen> {
  static const _channel = 'alerts';
  final _scrollCtrl = ScrollController();
  final Set<String> _demoAcknowledged = {};

  /// Local-only samples: patient assigned to you + ward / bed or bay location.
  static const _demoAllotments = <Map<String, String>>[
    {
      'id': 'demo-assign-er-1',
      'patient': 'Ravi Kumar',
      'ward': 'Emergency — Trauma',
      'location': 'Triage Bay 2 · Zone A',
      'detail': 'Assigned to you as lead physician. EMS handoff complete; FAST exam due.',
    },
    {
      'id': 'demo-assign-ward-2',
      'patient': 'Meera Joshi',
      'ward': 'General Medicine — Ward 3B',
      'location': 'Bed 14 · North wing',
      'detail': 'New admission allotted to your service. Vitals reviewed; insulin protocol started.',
    },
    {
      'id': 'demo-assign-obs-3',
      'patient': 'Farah Khan',
      'ward': 'Obstetrics — L&D',
      'location': 'Room OR-2 (pre-op holding)',
      'detail': 'Consult assigned: patient en route. Confirm epidural readiness with anesthesia.',
    },
    {
      'id': 'demo-assign-cardio-4',
      'patient': 'Sanjay Verma',
      'ward': 'Cardiology — CCU',
      'location': 'Telemetry Bed 6',
      'detail': 'STEMI rule-out track — you are covering. ECG at nursing station; review within 15 min.',
    },
    {
      'id': 'demo-assign-transfer-5',
      'patient': 'Anjali Patel',
      'ward': 'ICU — Step-down',
      'location': 'Bed 08 · West corridor',
      'detail': 'Transfer from ER accepted. Ward clerk updated location; family directed to waiting area W3.',
    },
  ];

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _alertTitle(DoctorAlertModel a) {
    switch (a.type) {
      case 'allotment':
        return 'Patient allotted to you';
      case 'checkin':
        return 'Patient checked-in';
      default:
        return 'New appointment';
    }
  }

  IconData _alertIcon(DoctorAlertModel a) {
    switch (a.type) {
      case 'allotment':
        return Icons.assignment_ind_outlined;
      case 'checkin':
        return Icons.qr_code_scanner;
      default:
        return Icons.event_available;
    }
  }

  Future<void> _ackFirestore(DoctorAlertModel a) async {
    if (a.read) return;
    try {
      await widget.firestoreService.acknowledgeDoctorAlert(
        doctorUid: widget.doctor.uid,
        alertId: a.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not acknowledge: $e'),
          backgroundColor: const Color(0xFFb91c1c),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertsQuery = FirebaseFirestore.instance
        .collection('doctor_alerts')
        .doc(widget.doctor.uid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(40);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF13132a),
            border: Border(bottom: BorderSide(color: Color(0xFF1e1e3a))),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined, color: Color(0xFFfbbf24), size: 18),
              const SizedBox(width: 8),
              Text(
                '#alerts',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0d0d1a),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF1e1e3a)),
                ),
                child: Text(
                  widget.doctor.onDuty ? 'On Duty' : 'Off Duty',
                  style: GoogleFonts.inter(
                    color: widget.doctor.onDuty ? const Color(0xFF4ade80) : const Color(0xFF9ca3af),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: alertsQuery.snapshots(),
            builder: (context, alertSnap) {
              return StreamBuilder<List<MessageModel>>(
                stream: widget.firestoreService.messagesStream(_channel),
                builder: (context, msgSnap) {
                  final alertDocs = alertSnap.data?.docs ?? const [];
                  final alerts = alertDocs.map((d) => DoctorAlertModel.fromDoc(d)).toList();
                  final msgs = msgSnap.data ?? const [];

                  if (alertSnap.connectionState == ConnectionState.waiting &&
                      msgSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
                    );
                  }

                  return ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    children: [
                      _demoShiftCard(context),
                      const SizedBox(height: 16),
                      Text(
                        'Patient allotments (Firestore)',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9ca3af),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (alerts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'No live allotments yet. When admin assigns you in Operations, alerts appear here.',
                            style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12, height: 1.35),
                          ),
                        )
                      else
                        ...alerts.map((a) => _firestoreAlertCard(context, a)),
                      const SizedBox(height: 8),
                      Text(
                        'Demo: patient assignment & ward location',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFf5a623),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sample alerts (not from Firestore) showing who you are assigned to and where they are placed.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6b7280),
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._demoAllotments
                          .where((d) => !_demoAcknowledged.contains(d['id']!))
                          .map(
                            (d) => _demoAllotmentCard(
                              id: d['id']!,
                              patient: d['patient']!,
                              ward: d['ward'] ?? '',
                              location: d['location'] ?? '',
                              detail: d['detail']!,
                            ),
                          ),
                      const SizedBox(height: 20),
                      Text(
                        'Channel: #alerts',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9ca3af),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (msgs.isEmpty) ...[
                        Text(
                          'Demo: broadcast #alerts (offline)',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFf5a623),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _demoBroadcastTile(
                          context,
                          sender: 'Ops Desk (demo)',
                          text:
                              'Surge protocol: ER wait > 45m — prioritize ESI-1/2 to bays 1–3. Fleet EMS-LKO-09 rerouted via Hazratganj.',
                        ),
                        _demoBroadcastTile(
                          context,
                          sender: 'Bed management (demo)',
                          text: 'ICU 2 beds opening after transfer ~19:00. Confirm handoff with Dr. Isha Tandon.',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Live Firebase messages replace this block when comms are connected.',
                          style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11, height: 1.35),
                        ),
                      ] else
                        ...msgs.map((m) => _commsMessageTile(context, m)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _demoShiftCard(BuildContext context) {
    final d = widget.doctor;
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day, 8, 0);
    final dayEnd = DateTime(now.year, now.month, now.day, 16, 0);
    final eveStart = DateTime(now.year, now.month, now.day, 16, 0);
    final eveEnd = DateTime(now.year, now.month, now.day, 23, 59);
    final ward = d.department.isNotEmpty ? d.department : (d.role.toLowerCase().contains('icu') ? 'ICU' : 'ER');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3f7cff).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e1b4b),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF7c3aed).withOpacity(0.45)),
                ),
                child: Text(
                  'DEMO SHIFTS',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFc4b5fd),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule, color: const Color(0xFF7c3aed).withOpacity(0.9), size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Today · $ward coverage',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${d.name} — you are on the demo roster as ${d.role}.',
            style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          _shiftRow('Day block', dayStart, dayEnd, 'Triage, consults, handoff notes 15:45'),
          const SizedBox(height: 8),
          _shiftRow('Evening overlap', eveStart, eveEnd, 'On-call backup + ICU cross-cover (demo)'),
          const SizedBox(height: 10),
          Text(
            'Real assignments sync from Firestore `shifts` when your hospital enables them.',
            style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _shiftRow(String label, DateTime start, DateTime end, String note) {
    String fmt(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final s = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$m $s';
    }

    final a = TimeOfDay.fromDateTime(start);
    final b = TimeOfDay.fromDateTime(end);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0d0d1a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1e1e3a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: const Color(0xFFa78bfa), fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            '${fmt(a)} – ${fmt(b)}',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(note, style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 11, height: 1.35)),
        ],
      ),
    );
  }

  Widget _demoBroadcastTile(BuildContext context, {required String sender, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFf5a623).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sender,
                style: GoogleFonts.inter(color: const Color(0xFFfbbf24), fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const Spacer(),
              Text(
                'demo',
                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: GoogleFonts.inter(color: const Color(0xFFd1d5db), fontSize: 13, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _firestoreAlertCard(BuildContext context, DoctorAlertModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: a.read ? const Color(0xFF1e1e3a) : const Color(0xFF7c3aed).withOpacity(0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: a.read ? const Color(0xFF1f2937) : const Color(0xFF7c3aed),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_alertIcon(a), color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _alertTitle(a),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.patientNameSnapshot.isEmpty ? 'Patient' : a.patientNameSnapshot,
                      style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                TimeOfDay.fromDateTime(a.createdAt).format(context),
                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: a.read ? null : () => _ackFirestore(a),
              child: Text(
                a.read ? 'Acknowledged' : 'Acknowledge',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: a.read ? const Color(0xFF6b7280) : const Color(0xFFa78bfa),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoAllotmentCard({
    required String id,
    required String patient,
    required String detail,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFf5a623).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF422006),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFf5a623).withOpacity(0.4)),
                ),
                child: Text(
                  'DEMO',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFfbbf24),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            patient,
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: GoogleFonts.inter(color: const Color(0xFFd1d5db), fontSize: 12, height: 1.35),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _demoAcknowledged.add(id)),
              child: Text(
                'Acknowledge',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFFfbbf24)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commsMessageTile(BuildContext context, MessageModel m) {
    final hazard = m.role == 'HAZARD ALERT' || m.text.startsWith('🚨');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hazard ? const Color(0xFFef4444).withOpacity(0.55) : const Color(0xFF1e1e3a),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  m.senderName.isEmpty ? 'Admin' : m.senderName,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                TimeOfDay.fromDateTime(m.timestamp).format(context),
                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.text,
            style: GoogleFonts.inter(
              color: hazard ? const Color(0xFFfca5a5) : const Color(0xFFd1d5db),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
