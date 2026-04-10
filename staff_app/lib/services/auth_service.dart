import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

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
