import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_model.dart';

class PatientAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<PatientModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    // Patient profile lives under patients/{uid}
    final doc = await _db.collection('patients').doc(user.uid).get();
    if (doc.exists) {
      return PatientModel.fromDoc(doc);
    }

    // First-time patient sign-in: create minimal profile (can be updated in intake screen)
    final profile = PatientModel(
      uid: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: email,
      phone: '',
    );
    await _db.collection('patients').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<PatientModel?> fetchProfile(String uid) async {
    final doc = await _db.collection('patients').doc(uid).get();
    if (!doc.exists) return null;
    return PatientModel.fromDoc(doc);
  }
}

