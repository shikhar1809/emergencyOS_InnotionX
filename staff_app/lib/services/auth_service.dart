import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Silent demo sign-in (no login UI). Create this user in Firebase Auth if missing.
  static const demoStaffEmail = 'staff.demo@goelhospital.com';
  static const demoStaffPassword = 'StaffDemo123';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// No login UI: sign in demo email account, **create it if missing**, or use anonymous auth.
  Future<void> ensureStaffSignedIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: demoStaffEmail,
        password: demoStaffPassword,
      );
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        rethrow;
      }
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: demoStaffEmail,
        password: demoStaffPassword,
      );
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await _auth.signInWithEmailAndPassword(
          email: demoStaffEmail,
          password: demoStaffPassword,
        );
        return;
      }
      if (e.code == 'operation-not-allowed') {
        await _auth.signInAnonymously();
        return;
      }
      rethrow;
    }
  }

  /// Load Firestore profile or create a minimal one (same as first-time email sign-in).
  Future<DoctorModel?> loadOrCreateStaffProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final existing = await fetchProfile(user.uid);
    if (existing != null) return existing;

    final email = user.email ??
        (user.isAnonymous ? 'staff.guest@local' : demoStaffEmail);
    final profile = DoctorModel(
      uid: user.uid,
      name: user.displayName ??
          (user.isAnonymous ? 'Staff (guest)' : email.split('@').first),
      email: email,
      role: 'Doctor',
      wardId: '',
      shiftId: '',
      onDuty: false,
      department: '',
    );
    await _db.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<DoctorModel?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return DoctorModel.fromDoc(doc);
    }

    // First-time sign-in: create a minimal profile
    final profile = DoctorModel(
      uid: user.uid,
      name: user.displayName ?? email.split('@').first,
      email: email,
      role: 'Doctor',
      wardId: '',
      shiftId: '',
      onDuty: false,
      department: '',
    );
    await _db.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({'onDuty': false});
    }
    await _auth.signOut();
  }

  Future<DoctorModel?> fetchProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return DoctorModel.fromDoc(doc);
  }
}
