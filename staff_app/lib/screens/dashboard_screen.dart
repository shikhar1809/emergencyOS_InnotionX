import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'alerts_only_screen.dart';
import 'shift_screen.dart';
import 'comms_screen.dart';
import 'login_screen.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  final DoctorModel doctor;
  const DashboardScreen({super.key, required this.doctor});

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
  bool _dutyPromptShown = false;
  bool _togglingDuty = false;

  static const _tabLabels = ['Alerts', 'Comms', 'Schedule'];
  static const _tabIcons = [
    Icons.warning_amber_outlined,
    Icons.chat_bubble_outline,
    Icons.schedule_outlined,
  ];
  static const _tabActiveIcons = [
    Icons.warning_amber,
    Icons.chat_bubble,
    Icons.schedule,
  ];

  List<Widget> _buildScreens(DoctorModel doc) => [
        AlertsOnlyScreen(doctor: doc, firestoreService: _firestoreService),
        CommsScreen(doctor: doc, firestoreService: _firestoreService),
        ShiftScreen(doctor: doc, firestoreService: _firestoreService),
      ];

  Future<void> _maybePromptDuty(DoctorModel doctor) async {
    if (_dutyPromptShown) return;
    if (doctor.onDuty) return;
    _dutyPromptShown = true;

    if (!mounted) return;
    final goOnDuty = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13132a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Go On Duty?',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Admin can only see you when you are On Duty. Turn it on now?',
          style: GoogleFonts.inter(color: const Color(0xFF9ca3af), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not now', style: GoogleFonts.inter(color: const Color(0xFF6b7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16a34a),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Go On Duty', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (goOnDuty == true) {
      try {
        await _firestoreService.setDutyStatus(doctor.uid, true);
        if (!mounted) return;
        setState(() => _selectedIndex = 0);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to go On Duty: $e'),
            backgroundColor: const Color(0xFFb91c1c),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleDuty(DoctorModel doctor) async {
    if (_togglingDuty) return;
    setState(() => _togglingDuty = true);
    try {
      await _firestoreService.setDutyStatus(doctor.uid, !doctor.onDuty);
      // Stream will update the UI; we just show quick feedback.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(doctor.onDuty ? 'Marked Off Duty' : 'Marked On Duty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update duty: $e'),
          backgroundColor: const Color(0xFFb91c1c),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _togglingDuty = false);
    }
  }

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
    _presenceTimer?.cancel();
    _presenceTimer = null;
    await _firestoreService.setPresenceOffline(doctor: doctor);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DoctorModel>(
      stream: _firestoreService.doctorStream(widget.doctor.uid),
      initialData: widget.doctor,
      builder: (context, snapshot) {
        final doctor = snapshot.data ?? widget.doctor;
        _latestDoctor = doctor;
        _startPresenceLoop(doctor);
        _maybePromptDuty(doctor);
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
                      'Staff Portal',
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
              // Duty toggle (moved to top)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: _togglingDuty ? null : () => _toggleDuty(doctor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doctor.onDuty ? const Color(0xFF16a34a) : const Color(0xFF374151),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  icon: _togglingDuty
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(doctor.onDuty ? Icons.toggle_on : Icons.toggle_off, size: 18),
                  label: Text(
                    doctor.onDuty ? 'On duty' : 'Off duty',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),

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
