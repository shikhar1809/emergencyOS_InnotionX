import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: StreamBuilder<List<MessageModel>>(
            stream: widget.firestoreService.messagesStream(_channel),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
                );
              }
              final msgs = snap.data ?? const [];
              if (msgs.isEmpty) {
                return Center(
                  child: Text(
                    'No alerts yet.',
                    style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 13),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                itemCount: msgs.length,
                itemBuilder: (ctx, i) {
                  final m = msgs[i];
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
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

