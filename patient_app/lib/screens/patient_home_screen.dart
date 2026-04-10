import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/appointment_model.dart';
import '../models/patient_model.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final PatientModel patient;
  const PatientHomeScreen({super.key, required this.patient});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final _auth = PatientAuthService();
  final _appointments = AppointmentService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  String _department = 'Emergency';
  String _serviceId = 'consult_general';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.patient.name;
    _phoneCtrl.text = widget.patient.phone;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _symptomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13132a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Sign out?',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'You will be signed out from the patient portal.',
          style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6b7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out', style: GoogleFonts.inter(color: const Color(0xFFf87171))),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PatientLoginScreen()),
    );
  }

  Future<void> _requestSlot() async {
    if (_submitting) return;
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final symptoms = _symptomsCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill name, phone, and symptoms.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFb91c1c),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final appt = await _appointments.createAppointment(
        patient: PatientModel(uid: widget.patient.uid, name: name, email: widget.patient.email, phone: phone),
        serviceId: _serviceId,
        department: _department,
        symptoms: symptoms,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slot created with ${appt.doctorNameSnapshot}.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create slot: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFb91c1c),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13132a),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF7c3aed),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_hospital, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EmergencyOS',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Patient Portal',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF6b7280),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1e1e3a)),
        ),
      ),
      body: StreamBuilder<AppointmentModel?>(
        stream: _appointments.latestAppointmentForPatient(widget.patient.uid),
        builder: (context, snap) {
          final appt = snap.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Your details'),
              const SizedBox(height: 10),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Full name'),
                    const SizedBox(height: 6),
                    _field(_nameCtrl, hint: 'Your name'),
                    const SizedBox(height: 12),
                    _label('Phone number'),
                    const SizedBox(height: 6),
                    _field(_phoneCtrl, hint: '+91…', keyboard: TextInputType.phone),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Consultation request'),
              const SizedBox(height: 10),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Department'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _department,
                      dropdownColor: const Color(0xFF0d0d1a),
                      items: const [
                        DropdownMenuItem(value: 'Emergency', child: Text('Emergency')),
                        DropdownMenuItem(value: 'Cardiology', child: Text('Cardiology')),
                        DropdownMenuItem(value: 'General', child: Text('General')),
                      ],
                      onChanged: _submitting ? null : (v) => setState(() => _department = v ?? 'Emergency'),
                      decoration: _decoration('Select department', Icons.apartment_outlined),
                    ),
                    const SizedBox(height: 12),
                    _label('Service'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _serviceId,
                      dropdownColor: const Color(0xFF0d0d1a),
                      items: const [
                        DropdownMenuItem(value: 'consult_general', child: Text('Consultation')),
                        DropdownMenuItem(value: 'followup', child: Text('Follow-up')),
                      ],
                      onChanged: _submitting ? null : (v) => setState(() => _serviceId = v ?? 'consult_general'),
                      decoration: _decoration('Select service', Icons.medical_services_outlined),
                    ),
                    const SizedBox(height: 12),
                    _label('Symptoms / reason'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _symptomsCtrl,
                      maxLines: 3,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: _decoration('Describe your symptoms', Icons.description_outlined),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _requestSlot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7c3aed),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF4c1d95),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text('Generate slot & QR',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Reception QR'),
              const SizedBox(height: 10),
              _card(
                child: appt == null
                    ? Text(
                        'No appointment yet. Submit details to generate a slot.',
                        style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Doctor: ${appt.doctorNameSnapshot}',
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Status: ${appt.status}',
                            style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                data: appt.receptionQrToken,
                                version: QrVersions.auto,
                                size: 220,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Show this QR at reception to check-in. Scanning triggers an alert to your assigned doctor.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );

  Widget _card({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13132a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1e1e3a)),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFd1d5db),
        ),
      );

  Widget _field(
    TextEditingController c, {
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: _decoration(hint, Icons.edit_outlined),
    );
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF374151), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6b7280), size: 18),
        filled: true,
        fillColor: const Color(0xFF0d0d1a),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7c3aed), width: 1.5),
        ),
      );
}

