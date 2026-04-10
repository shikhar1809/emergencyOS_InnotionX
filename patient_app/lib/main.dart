import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'models/patient_model.dart';
import 'screens/login_screen.dart';
import 'screens/patient_home_screen.dart';
import 'services/auth_service.dart';
import 'services/demo_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DemoSession.hydrate();
  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EmergencyOS — Patient Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7c3aed),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0d0d1a),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF13132a),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = PatientAuthService();
    return ValueListenableBuilder<bool>(
      valueListenable: DemoSession.activeNotifier,
      builder: (context, demoActive, _) {
        if (demoActive) {
          return PatientHomeScreen(patient: DemoSession.demoPatient(), isDemo: true);
        }

        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0d0d1a),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const PatientLoginScreen();
            }

            return FutureBuilder<PatientModel?>(
              future: authService.fetchProfile(user.uid),
              builder: (context, profileSnap) {
                if (profileSnap.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF0d0d1a),
                    body: Center(
                      child: CircularProgressIndicator(color: Color(0xFF7c3aed)),
                    ),
                  );
                }
                final patient = profileSnap.data;
                if (patient == null) {
                  FirebaseAuth.instance.signOut();
                  return const PatientLoginScreen();
                }
                return PatientHomeScreen(patient: patient);
              },
            );
          },
        );
      },
    );
  }
}

