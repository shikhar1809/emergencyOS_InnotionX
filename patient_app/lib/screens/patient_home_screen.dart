import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appointment_model.dart';
import '../models/patient_model.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../services/billing_push_service.dart';
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
  final _billingPush = BillingPushService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();

  String _department = 'Emergency';
  String _serviceId = 'consult_general';
  bool _submitting = false;
  int _bottomIndex = 0;
  String? _dismissedBillingPushToken;

  /// Local-only preview so reviewers can see slot + QR without Firestore approval.
  AppointmentModel? _demoAppointment;
  /// Extra demo fields (visit id, queue, bay) shown with the QR card.
  Map<String, String>? _demoBookingDetails;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.patient.name;
    _phoneCtrl.text = widget.patient.phone;
    _loadBillingPushDismissed();
  }

  Future<void> _loadBillingPushDismissed() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _dismissedBillingPushToken = p.getString('eos_billing_push_dismissed'));
  }

  Future<void> _dismissBillingPushBanner(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eos_billing_push_dismissed', token);
    if (!mounted) return;
    setState(() => _dismissedBillingPushToken = token);
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
      await _appointments.createAppointment(
        patient: PatientModel(uid: widget.patient.uid, name: name, email: widget.patient.email, phone: phone),
        serviceId: _serviceId,
        department: _department,
        symptoms: symptoms,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent. Waiting for admin approval…'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final friendly = msg.contains('permission-denied') || msg.contains('PERMISSION_DENIED')
          ? 'Could not submit request (Firestore permission). Check Firebase rules for appointments.'
          : 'Could not submit request: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendly),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFb91c1c),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showDemoSlotAndQr() {
    final now = DateTime.now();
    final name = _nameCtrl.text.trim().isEmpty ? widget.patient.name : _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().isEmpty ? widget.patient.phone : _phoneCtrl.text.trim();
    final visitId = 'VIS-LKO-${(now.millisecondsSinceEpoch % 900000) + 100000}';
    final queueNo = '${65 + (name.hashCode.abs() % 30)}';
    final bay = _department == 'Emergency' ? 'ER Triage — Desk A' : 'OPD — Counter 2';
    final start = now.add(const Duration(minutes: 8));
    final end = now.add(const Duration(minutes: 38));
    final doctorLabel = 'Dr. Aanya Verma';
    final payload = <String, dynamic>{
      'v': 1,
      'demo': true,
      'hospital': 'Goel Hospital — Lucknow (demo)',
      'visitId': visitId,
      'queue': queueNo,
      'patient': name,
      'phoneLast4': phone.length >= 4 ? phone.substring(phone.length - 4) : phone,
      'department': _department,
      'service': _serviceId,
      'assigned': doctorLabel,
      'windowStart': start.toIso8601String(),
      'windowEnd': end.toIso8601String(),
    };
    final qrPayload = jsonEncode(payload);
    setState(() {
      _demoBookingDetails = {
        'visitId': visitId,
        'queue': queueNo,
        'bay': bay,
        'window': '${_fmtSlot(start)} – ${_fmtSlot(end)}',
        'instructions': 'Bring photo ID. Arrive 10 minutes before your window. This pass is demo-only.',
      };
      _demoAppointment = AppointmentModel(
        id: 'demo-local-preview',
        patientUid: widget.patient.uid,
        patientNameSnapshot: name,
        serviceId: _serviceId,
        department: _department,
        doctorUid: 'demo-staff',
        doctorNameSnapshot: '$doctorLabel (demo)',
        status: 'scheduled',
        createdAt: now,
        scheduledStart: start,
        scheduledEnd: end,
        receptionQrToken: qrPayload,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo generated: slot, visit ID, queue, and QR (not saved to the server).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearDemoPreview() {
    setState(() {
      _demoAppointment = null;
      _demoBookingDetails = null;
    });
  }

  String _fmtSlot(DateTime dt) {
    final t = TimeOfDay.fromDateTime(dt);
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  String _serviceLabel(String id) {
    switch (id) {
      case 'followup':
        return 'Follow-up';
      case 'consult_general':
      default:
        return 'Consultation';
    }
  }

  Widget _demoDetailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              k,
              style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
      body: IndexedStack(
        index: _bottomIndex,
        children: [
          _buildHomeTab(),
          _buildBillsTab(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: const Color(0xFF4c1d95),
            labelTextStyle: WidgetStateProperty.resolveWith(
              (s) => GoogleFonts.inter(
                fontSize: 12,
                fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
                color: s.contains(WidgetState.selected) ? Colors.white : const Color(0xFF9ca3af),
              ),
            ),
            iconTheme: WidgetStateProperty.resolveWith(
              (s) => IconThemeData(
                color: s.contains(WidgetState.selected) ? const Color(0xFFc4b5fd) : const Color(0xFF6b7280),
              ),
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF13132a),
          surfaceTintColor: Colors.transparent,
          height: 64,
          selectedIndex: _bottomIndex,
          onDestinationSelected: (i) => setState(() => _bottomIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Bills',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return StreamBuilder<AppointmentModel?>(
      stream: _appointments.latestAppointmentForPatient(widget.patient.uid),
      builder: (context, snap) {
        final appt = _demoAppointment ?? snap.data;
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
                            : Text('Request slot',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _submitting ? null : _showDemoSlotAndQr,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFfbbf24),
                        side: const BorderSide(color: Color(0xFFf5a623)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Generate demo QR & slot',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
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
                        'No request yet. Submit details to request a slot.',
                        style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                      )
                    : appt.id == 'demo-local-preview'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      'DEMO PREVIEW',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFfbbf24),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _clearDemoPreview,
                                    child: Text(
                                      'Clear',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF9ca3af),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appt.doctorNameSnapshot,
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${appt.department} · ${_serviceLabel(appt.serviceId)}',
                                style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                              ),
                              if (_demoBookingDetails != null) ...[
                                const SizedBox(height: 12),
                                _demoDetailRow('Visit ID', _demoBookingDetails!['visitId']!),
                                _demoDetailRow('Queue #', _demoBookingDetails!['queue']!),
                                _demoDetailRow('Check-in desk', _demoBookingDetails!['bay']!),
                                _demoDetailRow('Slot window', _demoBookingDetails!['window']!),
                                const SizedBox(height: 6),
                                Text(
                                  _demoBookingDetails!['instructions']!,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF9ca3af),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
                              const SizedBox(height: 8),
                              Text(
                                'QR encodes JSON (demo). Reception scan would validate visitId + queue in production.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11, height: 1.35),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Not saved to the server — use Request slot for a real request.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12, height: 1.35),
                              ),
                            ],
                          )
                    : appt.status == 'cancelled'
                        ? Text(
                            'This request was cancelled or declined. Contact reception if you still need care.',
                            style: GoogleFonts.inter(color: const Color(0xFFf87171), fontSize: 13, height: 1.4),
                          )
                        : appt.isPendingApproval
                            ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
                                ),
                              ),
                              Text(
                                'Waiting for hospital approval',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your request is in the admin Operations queue. You will see your reception QR here once a staff member is assigned.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${appt.department} · ${appt.serviceId}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11),
                              ),
                            ],
                            )
                        : appt.canShowQr
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    appt.doctorNameSnapshot.isEmpty
                                        ? 'Assigned staff'
                                        : 'Doctor: ${appt.doctorNameSnapshot}',
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
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Status: ${appt.status}',
                                    style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  const Center(child: CircularProgressIndicator(color: Color(0xFF7c3aed))),
                                ],
                              ),
              ),
            ],
          );
        },
      );
  }

  Widget _buildBillsTab() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _billingPush.patientPushStream(),
      builder: (context, pushSnap) {
        final push = pushSnap.data;
        final token = push == null ? null : push['token']?.toString();
        final showPushBanner = push != null &&
            token != null &&
            token.isNotEmpty &&
            token != _dismissedBillingPushToken;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Check bills'),
            const SizedBox(height: 10),
            if (pushSnap.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Could not load billing messages (Firestore). Demo bill below still works offline.',
                  style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12, height: 1.4),
                ),
              ),
            if (showPushBanner)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: const Color(0xFF1e1b4b),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.campaign_outlined, color: Color(0xFFa78bfa), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                push['message']?.toString() ?? 'Update from billing',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.4),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _dismissBillingPushBanner(token),
                              icon: const Icon(Icons.close, color: Color(0xFF9ca3af), size: 20),
                              tooltip: 'Dismiss',
                            ),
                          ],
                        ),
                        if (push['billRef'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 32, top: 6),
                            child: Text(
                              '${push['billRef']} · INR ${push['amountInr'] ?? '—'}',
                              style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Cardiac consultation',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF422006),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFf59e0b)),
                        ),
                        child: Text(
                          'Pending',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFfbbf24),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'BL-2026-0091 · Cardiology / ER',
                    style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initial consult, ECG, and physician review (demo line item).',
                    style: GoogleFonts.inter(color: const Color(0xFFd1d5db), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount due',
                        style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 12),
                      ),
                      Text(
                        'INR 8,450',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When the hospital sends a request from Admin → Billings, it appears above (requires Firestore rules for demo_billing).',
              style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 11, height: 1.4),
            ),
          ],
        );
      },
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

