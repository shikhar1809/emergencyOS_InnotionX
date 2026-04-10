import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/doctor_model.dart';
import '../services/firestore_service.dart';

class DutyScreen extends StatefulWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const DutyScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  State<DutyScreen> createState() => _DutyScreenState();
}

class _DutyScreenState extends State<DutyScreen> {
  bool _toggling = false;

  Future<void> _toggle(bool current) async {
    setState(() => _toggling = true);
    try {
      await widget.firestoreService.setDutyStatus(
        widget.doctor.uid,
        !current,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: const Color(0xFFb91c1c),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onDuty = widget.doctor.onDuty;
    final now = DateFormat('EEEE, d MMM y · h:mm a').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Main duty toggle card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: onDuty
                    ? const Color(0xFF16a34a).withOpacity(0.4)
                    : const Color(0xFF1e1e3a),
              ),
              boxShadow: onDuty
                  ? [
                      BoxShadow(
                        color: const Color(0xFF16a34a).withOpacity(0.1),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                // Animated status ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onDuty
                        ? const Color(0xFF14532d).withOpacity(0.3)
                        : const Color(0xFF1f2937),
                    border: Border.all(
                      color: onDuty ? const Color(0xFF4ade80) : const Color(0xFF374151),
                      width: 3,
                    ),
                    boxShadow: onDuty
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4ade80).withOpacity(0.25),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    onDuty ? Icons.medical_services : Icons.medical_services_outlined,
                    size: 52,
                    color: onDuty ? const Color(0xFF4ade80) : const Color(0xFF4b5563),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  onDuty ? 'ON DUTY' : 'OFF DUTY',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: onDuty ? const Color(0xFF4ade80) : const Color(0xFF6b7280),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  onDuty
                      ? 'You are currently on duty and visible to admin.'
                      : 'You are currently off duty.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6b7280),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  now,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF4b5563),
                  ),
                ),
                const SizedBox(height: 32),

                // Toggle button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _toggling ? null : () => _toggle(onDuty),
                    icon: _toggling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(onDuty ? Icons.toggle_off : Icons.toggle_on, size: 22),
                    label: Text(
                      _toggling
                          ? 'Updating...'
                          : onDuty
                              ? 'Go Off Duty'
                              : 'Go On Duty',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          onDuty ? const Color(0xFFb91c1c) : const Color(0xFF16a34a),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF60a5fa), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Duty Status Info',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _infoItem('Your status is visible in real-time to the admin panel.'),
                _infoItem('Signing out automatically sets you to Off Duty.'),
                _infoItem('Only On Duty staff appear in ward and shift reports.'),
                _infoItem('Hazard alerts can be raised regardless of duty status.'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Staff info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF7c3aed),
                  child: Text(
                    widget.doctor.name.isNotEmpty
                        ? widget.doctor.name[0].toUpperCase()
                        : 'D',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.doctor.role,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9ca3af),
                        ),
                      ),
                      if (widget.doctor.department.isNotEmpty)
                        Text(
                          widget.doctor.department,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6b7280),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 5, color: Color(0xFF4b5563)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6b7280)),
            ),
          ),
        ],
      ),
    );
  }
}
