import 'dart:async';

import 'package:flutter/material.dart';

import '../services/fleet_storage.dart';
import 'fleet_login_screen.dart';
import 'fleet_portal_screen.dart';

class FleetGate extends StatefulWidget {
  const FleetGate({super.key});

  @override
  State<FleetGate> createState() => _FleetGateState();
}

class _FleetGateState extends State<FleetGate> {
  String? _email;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _email = FleetStorage.getSessionEmail();
    // Keep session in sync across tabs/navigation.
    _poll = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = FleetStorage.getSessionEmail();
      if (now != _email) {
        setState(() => _email = now);
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_email == null || _email!.trim().isEmpty) {
      return const FleetLoginScreen();
    }
    return FleetPortalScreen(email: _email!);
  }
}

