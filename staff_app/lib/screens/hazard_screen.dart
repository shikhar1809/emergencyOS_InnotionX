import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';
import '../models/shift_model.dart';
import '../services/firestore_service.dart';

class HazardScreen extends StatefulWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const HazardScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  State<HazardScreen> createState() => _HazardScreenState();
}

class _HazardScreenState extends State<HazardScreen> {
  final _descCtrl = TextEditingController();
  String? _selectedWardId;
  String _selectedWardName = '';
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctor.wardId.isNotEmpty) {
      _selectedWardId = widget.doctor.wardId;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _raise() async {
    if (_selectedWardId == null || _selectedWardId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a ward first.'),
          backgroundColor: Color(0xFFb91c1c),
        ),
      );
      return;
    }
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the hazard.'),
          backgroundColor: Color(0xFFb91c1c),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFef4444), size: 22),
            const SizedBox(width: 8),
            Text('Raise Hazard Alert?',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'This will alert the admin and post to #alerts channel immediately.',
          style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6b7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFb91c1c),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('RAISE ALERT', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await widget.firestoreService.raiseHazard(
        reportedBy: widget.doctor.uid,
        reportedByName: widget.doctor.name,
        wardId: _selectedWardId!,
        wardName: _selectedWardName,
        description: _descCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _submitted = true;
          _descCtrl.clear();
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _submitted = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to raise hazard: $e'),
            backgroundColor: const Color(0xFFb91c1c),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_submitted) _successBanner(),
          const SizedBox(height: 4),

          // Raise hazard form
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1a0a0a),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7f1d1d).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2a0a0a),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFb91c1c).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.warning_amber,
                            color: Color(0xFFef4444), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Raise Hazard Alert',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Immediately notifies admin + posts to #alerts',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: const Color(0xFF9ca3af)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ward selector
                      Text('Ward / Location',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFd1d5db))),
                      const SizedBox(height: 6),
                      StreamBuilder<List<WardModel>>(
                        stream: widget.firestoreService.allWardsStream(),
                        builder: (context, snap) {
                          final wards = snap.data ?? [];
                          if (_selectedWardId != null && _selectedWardName.isEmpty) {
                            final match = wards
                                .where((w) => w.id == _selectedWardId)
                                .toList();
                            if (match.isNotEmpty) {
                              _selectedWardName = match.first.name;
                            }
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedWardId,
                            dropdownColor: const Color(0xFF13132a),
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 13),
                            decoration: _inputDeco('Select ward...'),
                            items: [
                              if (wards.isEmpty)
                                DropdownMenuItem(
                                  value: 'unknown',
                                  child: Text('Unknown / General',
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontSize: 13)),
                                ),
                              ...wards.map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(w.name,
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontSize: 13)),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _selectedWardId = v;
                                _selectedWardName = wards
                                    .firstWhere(
                                      (w) => w.id == v,
                                      orElse: () => WardModel(
                                          id: '', name: 'Unknown', floor: '', totalBeds: 0, occupiedBeds: 0),
                                    )
                                    .name;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Text('Hazard Description',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFd1d5db))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: _inputDeco(
                            'Describe the hazard clearly (e.g. "Gas leak near ICU", "Equipment failure in OT-2")...'),
                      ),
                      const SizedBox(height: 20),

                      // Raise button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitting ? null : _raise,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.warning_amber, size: 20),
                          label: Text(
                            _submitting ? 'Raising Alert...' : 'RAISE HAZARD ALERT',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFb91c1c),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Active hazards list
          Row(
            children: [
              const Icon(Icons.list_alt_outlined, color: Color(0xFFf87171), size: 16),
              const SizedBox(width: 8),
              Text(
                'Active Hazards',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _activeHazardsList(),
        ],
      ),
    );
  }

  Widget _successBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14532d).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF16a34a).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4ade80), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hazard alert raised! Admin notified and posted to #alerts.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF4ade80)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeHazardsList() {
    return StreamBuilder<List<HazardModel>>(
      stream: widget.firestoreService.activeHazardsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7c3aed)));
        }
        final hazards = snap.data ?? [];
        if (hazards.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Color(0xFF4ade80), size: 18),
                const SizedBox(width: 8),
                Text('No active hazards. All clear.',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF4b5563), fontSize: 13)),
              ],
            ),
          );
        }
        return Column(
          children: hazards.map((h) => _hazardTile(h)).toList(),
        );
      },
    );
  }

  Widget _hazardTile(HazardModel h) {
    final df = DateFormat('d MMM, h:mm a');
    final isMyHazard = h.reportedBy == widget.doctor.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1a0a0a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMyHazard
              ? const Color(0xFFef4444).withOpacity(0.4)
              : const Color(0xFF7f1d1d).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFef4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        h.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isMyHazard)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7f1d1d).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('You',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFfca5a5))),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${h.wardName} · ${h.reportedByName} · ${df.format(h.timestamp)}',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF9ca3af)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF374151), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0d0d1a),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2a1010)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2a1010)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFef4444), width: 1.5),
        ),
      );
}
