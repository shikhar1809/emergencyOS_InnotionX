import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../models/shift_model.dart';
import '../services/firestore_service.dart';

class WardScreen extends StatelessWidget {
  final DoctorModel doctor;
  final FirestoreService firestoreService;

  const WardScreen({
    super.key,
    required this.doctor,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WardModel?>(
      stream: firestoreService.wardStream(doctor.wardId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7c3aed)));
        }
        final ward = snapshot.data;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assigned Ward
              _sectionHeader('Assigned Ward', Icons.meeting_room, const Color(0xFF818cf8)),
              const SizedBox(height: 10),
              if (ward == null)
                _noWardCard()
              else
                _wardDetailCard(ward),

              const SizedBox(height: 24),

              // All Wards Overview
              _sectionHeader('All Wards', Icons.domain_outlined, const Color(0xFF60a5fa)),
              const SizedBox(height: 10),
              _allWardsSection(),
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

  Widget _noWardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e1e3a)),
      ),
      child: Column(
        children: [
          const Icon(Icons.meeting_room_outlined, color: Color(0xFF4b5563), size: 40),
          const SizedBox(height: 10),
          Text(
            'No ward assigned yet.',
            style: GoogleFonts.inter(color: const Color(0xFF6b7280), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Contact admin to get assigned to a ward.',
            style: GoogleFonts.inter(color: const Color(0xFF4b5563), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _wardDetailCard(WardModel ward) {
    final occupancy = ward.occupancyRate;
    Color occupancyColor;
    if (occupancy < 0.6) {
      occupancyColor = const Color(0xFF4ade80);
    } else if (occupancy < 0.85) {
      occupancyColor = const Color(0xFFfbbf24);
    } else {
      occupancyColor = const Color(0xFFf87171);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4c1d95).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1a0a3a),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.meeting_room, color: Color(0xFF818cf8), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.name,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Floor ${ward.floor}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9ca3af),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF7c3aed).withOpacity(0.4)),
                  ),
                  child: Text(
                    'YOUR WARD',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFa78bfa),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _statTile('Total Beds', ward.totalBeds.toString(), Icons.bed_outlined, const Color(0xFF60a5fa))),
                    const SizedBox(width: 10),
                    Expanded(child: _statTile('Occupied', ward.occupiedBeds.toString(), Icons.person_outlined, occupancyColor)),
                    const SizedBox(width: 10),
                    Expanded(child: _statTile('Free', ward.freeBeds.toString(), Icons.check_circle_outline, const Color(0xFF4ade80))),
                  ],
                ),
                const SizedBox(height: 14),
                // Occupancy bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Occupancy',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6b7280))),
                        Text('${(occupancy * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: occupancyColor,
                            )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancy,
                        backgroundColor: const Color(0xFF1e1e3a),
                        valueColor: AlwaysStoppedAnimation(occupancyColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6b7280)),
          ),
        ],
      ),
    );
  }

  Widget _allWardsSection() {
    return StreamBuilder<List<WardModel>>(
      stream: firestoreService.allWardsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7c3aed)));
        }
        final wards = snapshot.data ?? [];
        if (wards.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF13132a),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1e1e3a)),
            ),
            child: Text('No ward data available.',
                style: GoogleFonts.inter(color: const Color(0xFF4b5563), fontSize: 13)),
          );
        }
        return Column(
          children: wards.map((w) => _wardRow(w)).toList(),
        );
      },
    );
  }

  Widget _wardRow(WardModel ward) {
    final occ = ward.occupancyRate;
    Color color = occ < 0.6
        ? const Color(0xFF4ade80)
        : occ < 0.85
            ? const Color(0xFFfbbf24)
            : const Color(0xFFf87171);
    final isAssigned = ward.id == doctor.wardId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAssigned
            ? const Color(0xFF1a0a3a)
            : const Color(0xFF13132a),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAssigned ? const Color(0xFF4c1d95) : const Color(0xFF1e1e3a),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ward.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isAssigned) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7c3aed).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('You',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFa78bfa))),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Floor ${ward.floor}',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6b7280)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ward.occupiedBeds}/${ward.totalBeds}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text('beds', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6b7280))),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: occ,
              backgroundColor: const Color(0xFF1e1e3a),
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 4,
            ),
          ),
        ],
      ),
    );
  }
}
