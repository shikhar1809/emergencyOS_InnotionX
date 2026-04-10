import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/doctor_alert_model.dart';

class AlertsScreen extends StatelessWidget {
  final String doctorUid;
  const AlertsScreen({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('doctor_alerts')
        .doc(doctorUid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(50);

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        title: Text('Alerts', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1e1e3a)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
            );
          }
          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No alerts yet.',
                style: GoogleFonts.inter(color: const Color(0xFF9ca3af)),
              ),
            );
          }

          final alerts = docs.map((d) => DoctorAlertModel.fromDoc(d)).toList();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final a = alerts[i];
              final title = a.type == 'checkin' ? 'Patient checked-in' : 'New appointment';
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF13132a),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1e1e3a)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: a.read ? const Color(0xFF1f2937) : const Color(0xFF7c3aed),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        a.type == 'checkin' ? Icons.qr_code_scanner : Icons.event_available,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            a.patientNameSnapshot.isEmpty ? 'Patient' : a.patientNameSnapshot,
                            style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      TimeOfDay.fromDateTime(a.createdAt).format(context),
                      style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

