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

  static const _demoAllotments = <Map<String, String>>[
    {
      'id': 'local-demo-allot-1',
      'patient': 'Ravi Kumar',
      'detail': 'ER trauma — you are allotted as lead physician. Triage bay 2.',
    },
    {
      'id': 'local-demo-allot-2',
      'patient': 'Farah Khan',
      'detail': 'Obstetrics consult — patient en route; confirm bed readiness.',
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
                        'Demo: patient allotments',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFf5a623),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._demoAllotments
                          .where((d) => !_demoAcknowledged.contains(d['id']!))
                          .map(
                            (d) => _demoAllotmentCard(
                              id: d['id']!,
                              patient: d['patient']!,
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
                      if (msgs.isEmpty)
                        Text(
                          'No broadcast messages in #alerts yet.',
                          style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12),
                        )
                      else
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
