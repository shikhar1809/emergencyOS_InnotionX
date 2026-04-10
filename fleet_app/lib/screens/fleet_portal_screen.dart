import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../services/fleet_auth.dart';
import '../services/fleet_storage.dart';

enum FleetPortalState { offDuty, waiting, assigned }

class FleetPortalScreen extends StatefulWidget {
  const FleetPortalScreen({super.key, required this.email});

  final String email;

  @override
  State<FleetPortalScreen> createState() => _FleetPortalScreenState();
}

class _FleetPortalScreenState extends State<FleetPortalScreen> {
  FleetPortalState _state = FleetPortalState.offDuty;
  Timer? _poll;
  Map<String, dynamic>? _assignment;

  @override
  void initState() {
    super.initState();
    _syncFromStorage(initial: true);
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _syncFromStorage());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _syncFromStorage({bool initial = false}) {
    final email = widget.email;

    final assignment = FleetStorage.getAssignmentFor(email);
    if (assignment != null && (assignment['incident']?.toString().trim().isNotEmpty ?? false)) {
      if (!mounted) return;
      setState(() {
        _assignment = assignment;
        _state = FleetPortalState.assigned;
      });
      return;
    }

    final onDuty = FleetStorage.getOnDutyMap()[email] == true;
    if (!mounted) return;
    setState(() {
      _assignment = null;
      _state = onDuty ? FleetPortalState.waiting : FleetPortalState.offDuty;
    });
  }

  void _setOnDuty(bool onDuty) {
    FleetStorage.setOnDuty(widget.email, onDuty);
    _syncFromStorage();
  }

  void _signOut() {
    FleetStorage.setOnDuty(widget.email, false);
    FleetStorage.clearSessionEmail();
  }

  void _markComplete() {
    FleetStorage.clearAssignmentFor(widget.email);
    _setOnDuty(true);
  }

  @override
  Widget build(BuildContext context) {
    final titleBadge = switch (_state) {
      FleetPortalState.offDuty => _Badge(text: 'OFF DUTY', bg: const Color(0xFF414752), fg: Colors.white),
      FleetPortalState.waiting => _Badge(text: 'ON DUTY', bg: const Color(0xFF1B5E20), fg: const Color(0xFFA5D6A7)),
      FleetPortalState.assigned => _Badge(text: 'ASSIGNED', bg: const Color(0xFFA90111), fg: const Color(0xFFFFB4AC)),
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EmergencyOS', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Color(0xFFC1C6D4), fontWeight: FontWeight.w700)),
            SizedBox(height: 2),
            Text('Fleet Operator Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: titleBadge),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _OperatorStrip(email: widget.email),
              const SizedBox(height: 12),
              if (_state == FleetPortalState.offDuty) ...[
                _StatusCard(state: _state),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _setOnDuty(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: const Color(0xFF003258),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Go On Duty', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF414752)),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _signOut,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB4AC),
                      side: const BorderSide(color: Color(0xFFFFB4AC), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
              if (_state == FleetPortalState.waiting) ...[
                _StatusCard(state: _state),
                const SizedBox(height: 12),
                _WaitingCard(),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _setOnDuty(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB4AC),
                      side: const BorderSide(color: Color(0xFFFFB4AC), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Go Off Duty', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
              if (_state == FleetPortalState.assigned) ...[
                _AssignedView(
                  assignment: _assignment ?? const <String, dynamic>{},
                  onMarkComplete: _markComplete,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                FleetAuth.displayNameFromEmail(widget.email),
                style: const TextStyle(color: Color(0xFFC1C6D4), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperatorStrip extends StatelessWidget {
  const _OperatorStrip({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF414752)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_outline, color: Color(0xFFC1C6D4), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Operator', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: Color(0xFFC1C6D4), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final FleetPortalState state;

  @override
  Widget build(BuildContext context) {
    final isOn = state != FleetPortalState.offDuty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF414752)),
      ),
      child: Column(
        children: [
          const Text('Current Status', style: TextStyle(color: Color(0xFFC1C6D4), fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 12)),
          const SizedBox(height: 10),
          Text(isOn ? 'ON DUTY' : 'OFF DUTY', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isOn ? const Color(0xFFA5D6A7) : const Color(0xFFC1C6D4))),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('OFF', style: TextStyle(color: Color(0xFFC1C6D4), fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Container(
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: isOn ? const Color(0xFF4CAF50) : const Color(0xFF414752),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                padding: const EdgeInsets.all(3),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
                ),
              ),
              const SizedBox(width: 10),
              Text('ON', style: TextStyle(color: isOn ? Colors.white : const Color(0xFFC1C6D4), fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF414752)),
      ),
      child: Column(
        children: const [
          SizedBox(height: 8),
          _Pulse(),
          SizedBox(height: 16),
          Text('WAITING FOR ASSIGNMENT', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
          SizedBox(height: 6),
          Text('Stand by — dispatch will assign you shortly', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC1C6D4))),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _ring(120, t),
              _ring(150, (t + 0.33) % 1.0),
              _ring(180, (t + 0.66) % 1.0),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.wifi_tethering, color: Color(0xFFA5D6A7), size: 32),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double size, double t) {
    final opacity = (1 - t).clamp(0.0, 1.0);
    final scale = 0.85 + (0.35 * t);
    return Opacity(
      opacity: 0.5 * opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      ),
    );
  }
}

class _AssignedView extends StatelessWidget {
  const _AssignedView({required this.assignment, required this.onMarkComplete});

  final Map<String, dynamic> assignment;
  final VoidCallback onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final incident = (assignment['incident'] ?? '—').toString();
    final destination = (assignment['destination'] ?? '—').toString();
    final assignedAt = (assignment['assignedAt'] ?? '').toString();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: const Border(left: BorderSide(color: Color(0xFFFFB4AC), width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('⚠ INCIDENT ASSIGNED', style: TextStyle(color: Color(0xFFFFB4AC), fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12)),
              SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF414752)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Incident', style: TextStyle(color: Color(0xFFC1C6D4), fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12)),
              const SizedBox(height: 6),
              Text(incident, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA90111),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('HIGH PRIORITY', style: TextStyle(color: Color(0xFFFFB4AC), fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11)),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.location_on_outlined, color: Color(0xFFC1C6D4)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Destination', style: TextStyle(color: Color(0xFFC1C6D4), fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(destination, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final url = Uri.parse(
                'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}',
              );
              html.window.open(url.toString(), '_blank');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.navigation_outlined),
            label: const Text('Open in Google Maps', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onMarkComplete,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA5D6A7),
              side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        if (assignedAt.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Assigned at $assignedAt', style: const TextStyle(color: Color(0xFFC1C6D4), fontSize: 12)),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
    );
  }
}

