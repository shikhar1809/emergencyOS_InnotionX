import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/fleet_gate.dart';

void main() {
  runApp(const FleetApp());
}

class FleetApp extends StatelessWidget {
  const FleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmergencyOS — Fleet Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF131313),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF131313),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const FleetGate(),
    );
  }
}

