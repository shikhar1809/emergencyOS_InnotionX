import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/demo_session.dart';
import 'shift_screen.dart';
import 'ward_screen.dart';
import 'duty_screen.dart';
import 'comms_screen.dart';
import 'hazard_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final DoctorModel doctor;
  final bool isDemo;
  const DashboardScreen({super.key, required this.doctor, this.isDemo = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  Timer? _presenceTimer;
  DoctorModel? _latestDoctor;

  static const _tabLabels = ['Shifts', 'Ward', 'Duty', 'Comms', 'Hazard'];
  static const _tabIcons = [
    Icons.schedule_outlined,
    Icons.meeting_room_outlined,
    Icons.toggle_on_outlined,
    Icons.chat_bubble_outline,
    Icons.warning_amber_outlined,
  ];
  static const _tabActiveIcons = [
    Icons.schedule,
    Icons.meeting_room,
    Icons.toggle_on,
    Icons.chat_bubble,
    Icons.warning_amber,
  ];

  List<Widget> _buildScreens(DoctorModel doc) => [
        ShiftScreen(doctor: doc, firestoreService: _firestoreService),
        WardScreen(doctor: doc, firestoreService: _firestoreService),
        DutyScreen(doctor: doc, firestoreService: _firestoreService),
        CommsScreen(doctor: doc, firestoreService: _firestoreService),
        HazardScreen(doctor: doc, firestoreService: _firestoreService),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceTimer?.cancel();
    super.dispose();
  }

  void _startPresenceLoop(DoctorModel doctor) {
    if (widget.isDemo) return;
    // Avoid restarting timer excessively.
    if (_presenceTimer != null) return;

    // Mark online immediately.
    _firestoreService.setPresenceOnline(doctor: doctor);

    _presenceTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      final doc = _latestDoctor ?? doctor;
      _firestoreService.heartbeatPresence(doctor: doc);
    });
  }

  Future<void> _stopPresenceLoopAndSetOffline(DoctorModel doctor) async {
    if (widget.isDemo) return;
    _presenceTimer?.cancel();
    _presenceTimer = null;
    await _firestoreService.setPresenceOffline(doctor: doctor);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.isDemo) return;
    final doc = _latestDoctor ?? widget.doctor;
    if (state == AppLifecycleState.resumed) {
      _firestoreService.setPresenceOnline(doctor: doc, state: 'online');
      _presenceTimer ??= Timer.periodic(const Duration(seconds: 45), (_) {
        final d = _latestDoctor ?? doc;
        _firestoreService.heartbeatPresence(doctor: d, state: 'online');
      });
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Best-effort: mark offline when app isn't usable.
      _firestoreService.setPresenceOffline(doctor: doc);
      _presenceTimer?.cancel();
      _presenceTimer = null;
    }
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
          'You will be marked as Off Duty and signed out.',
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
    if (confirmed == true) {
      final doc = _latestDoctor ?? widget.doctor;
      await _stopPresenceLoopAndSetOffline(doc);
      if (widget.isDemo) {
        await DemoSession.disable();
      } else {
        await _authService.signOut();
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDemo) {
      final doctor = widget.doctor;
      _latestDoctor = doctor;
      final screens = _buildScreens(doctor);
      return _buildScaffold(doctor: doctor, screens: screens);
    }

    return StreamBuilder<DoctorModel>(
      stream: _firestoreService.doctorStream(widget.doctor.uid),
      initialData: widget.doctor,
      builder: (context, snapshot) {
        final doctor = snapshot.data ?? widget.doctor;
        _latestDoctor = doctor;
        _startPresenceLoop(doctor);
        final screens = _buildScreens(doctor);

        return _buildScaffold(
          doctor: doctor,
          screens: screens,
        );
      },
    );
  }

  Widget _buildScaffold({required DoctorModel doctor, required List<Widget> screens}) {
    return Scaffold(
          backgroundColor: const Color(0xFF0d0d1a),
          appBar: AppBar(
            backgroundColor: const Color(0xFF13132a),
            elevation: 0,
            titleSpacing: 16,
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
                      widget.isDemo ? 'Staff Portal · DEMO' : 'Staff Portal',
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
              // Duty status badge
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: doctor.onDuty
                      ? const Color(0xFF14532d).withOpacity(0.6)
                      : const Color(0xFF1f2937),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: doctor.onDuty ? const Color(0xFF16a34a) : const Color(0xFF374151),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: doctor.onDuty
                            ? const Color(0xFF4ade80)
                            : const Color(0xFF6b7280),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      doctor.onDuty ? 'On Duty' : 'Off Duty',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: doctor.onDuty
                            ? const Color(0xFF4ade80)
                            : const Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Doctor avatar / name
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: PopupMenuButton<String>(
                  color: const Color(0xFF13132a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1e1e3a)),
                  ),
                  offset: const Offset(0, 40),
                  onSelected: (v) {
                    if (v == 'signout') _signOut();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name,
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(doctor.role,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF6b7280), fontSize: 11)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'signout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Color(0xFFf87171), size: 16),
                          const SizedBox(width: 8),
                          Text('Sign Out',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFf87171), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF7c3aed),
                    child: Text(
                      doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFF1e1e3a)),
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF13132a),
              border: Border(top: BorderSide(color: Color(0xFF1e1e3a))),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF7c3aed),
              unselectedItemColor: const Color(0xFF4b5563),
              selectedLabelStyle: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
              items: List.generate(
                _tabLabels.length,
                (i) => BottomNavigationBarItem(
                  icon: Icon(_tabIcons[i]),
                  activeIcon: i == 4
                      ? Icon(_tabActiveIcons[i], color: const Color(0xFFef4444))
                      : Icon(_tabActiveIcons[i]),
                  label: _tabLabels[i],
                ),
              ),
            ),
          ),
        );
  }
}
