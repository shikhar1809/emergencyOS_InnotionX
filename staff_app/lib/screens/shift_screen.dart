import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/doctor_model.dart';
import '../models/shift_model.dart';
import '../services/firestore_service.dart';

class ShiftScreen extends StatelessWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const ShiftScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ShiftModel>>(
      stream: firestoreService.shiftsForUser(doctor.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7c3aed)));
        }
        final shifts = snapshot.data ?? [];
        final now = DateTime.now();
        final current = shifts.where((s) => s.isActive).toList();
        final upcoming = shifts
            .where((s) => s.startTime.isAfter(now))
            .take(5)
            .toList();
        final past = shifts
            .where((s) => s.endTime.isBefore(now) && !s.isActive)
            .take(3)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Current Shift', Icons.schedule, const Color(0xFF4ade80)),
              const SizedBox(height: 10),
              if (current.isEmpty)
                _emptyCard('No active shift right now.')
              else
                ...current.map((s) => _shiftCard(s, isActive: true)),

              const SizedBox(height: 24),
              _sectionHeader('Upcoming Shifts', Icons.calendar_today_outlined, const Color(0xFF818cf8)),
              const SizedBox(height: 10),
              if (upcoming.isEmpty)
                _emptyCard('No upcoming shifts scheduled.')
              else
                ...upcoming.map((s) => _shiftCard(s, isActive: false)),

              if (past.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionHeader('Recent Past', Icons.history, const Color(0xFF6b7280)),
                const SizedBox(height: 10),
                ...past.map((s) => _shiftCard(s, isActive: false, isPast: true)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e1e3a)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: const Color(0xFF4b5563), fontSize: 13),
      ),
    );
  }

  Widget _shiftCard(ShiftModel shift, {required bool isActive, bool isPast = false}) {
    final df = DateFormat('d MMM, h:mm a');
    final tf = DateFormat('h:mm a');

    Color accent = isActive ? const Color(0xFF4ade80) : const Color(0xFF818cf8);
    if (isPast) accent = const Color(0xFF374151);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF16a34a).withOpacity(0.4) : const Color(0xFF1e1e3a),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shift.label,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isPast ? const Color(0xFF6b7280) : Colors.white,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14532d).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF16a34a)),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4ade80),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _infoRow(Icons.access_time_outlined,
                          '${df.format(shift.startTime)} → ${tf.format(shift.endTime)}'),
                      const SizedBox(height: 4),
                      _infoRow(Icons.meeting_room_outlined, shift.wardName.isNotEmpty ? shift.wardName : 'Ward TBD'),
                      const SizedBox(height: 4),
                      _infoRow(Icons.timer_outlined, shift.durationLabel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF6b7280)),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9ca3af)),
        ),
      ],
    );
  }
}
