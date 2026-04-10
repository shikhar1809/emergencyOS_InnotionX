import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/doctor_model.dart';
import '../services/reception_service.dart';

class ReceptionCheckInScreen extends StatefulWidget {
  final DoctorModel staff;
  const ReceptionCheckInScreen({super.key, required this.staff});

  @override
  State<ReceptionCheckInScreen> createState() => _ReceptionCheckInScreenState();
}

class _ReceptionCheckInScreenState extends State<ReceptionCheckInScreen> {
  final _svc = ReceptionService();
  final _manualCtrl = TextEditingController();
  bool _busy = false;
  String? _lastToken;

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIn(String token) async {
    if (_busy) return;
    final t = token.trim();
    if (t.isEmpty) return;
    setState(() {
      _busy = true;
      _lastToken = t;
    });
    try {
      await _svc.checkInByReceptionToken(
        receptionQrToken: t,
        scannedByUid: widget.staff.uid,
        scannedByName: widget.staff.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checked in. Doctor alerted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in failed: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFb91c1c),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      appBar: AppBar(
        title: Text('Reception check-in', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1e1e3a)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Scan patient QR',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: MobileScanner(
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;
                        final raw = barcodes.first.rawValue;
                        if (raw == null || raw.isEmpty) return;
                        if (raw == _lastToken) return; // simple de-dupe
                        _checkIn(raw);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'If camera scanning is blocked, paste the QR token below.',
                  style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Manual token', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                TextField(
                  controller: _manualCtrl,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Paste QR token',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF374151), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFF0d0d1a),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _busy ? null : () => _checkIn(_manualCtrl.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7c3aed),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF4c1d95),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text('Check in', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

