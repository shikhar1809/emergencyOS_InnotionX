import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _cardBorder = Color(0xFF1e1e3a);
  static const _muted = Color(0xFF6b7280);

  /// Must match a Firebase Auth user you create for demos (same domain pattern as fleet app).
  static const _demoEmail = 'staff.demo@goelhospital.com';
  static const _demoPassword = 'StaffDemo123';

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final doctor = await _authService.signIn(_emailCtrl.text, _passCtrl.text);
      if (!mounted) return;
      if (doctor != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(doctor: doctor)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Sign in failed. Please check your credentials.';
      if (e.code == 'user-not-found') msg = 'No account found for this email.';
      if (e.code == 'wrong-password') msg = 'Incorrect password.';
      if (e.code == 'invalid-email') msg = 'Invalid email address.';
      if (e.code == 'too-many-requests') msg = 'Too many attempts. Try again later.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFb91c1c),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFb91c1c),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyDemoCredentials() {
    setState(() {
      _emailCtrl.text = _demoEmail;
      _passCtrl.text = _demoPassword;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Filled demo email/password. Tap Sign in (create this user in Firebase Auth if needed).',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1e1e3a),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 640;

    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Logo / header
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7c3aed),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7c3aed).withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.white, size: 36),
                ),
                SizedBox(height: compact ? 12 : 24),
                Text(
                  'EmergencyOS',
                  style: GoogleFonts.inter(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Staff Portal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9ca3af),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _applyDemoCredentials,
                  icon: const Icon(Icons.key_outlined, size: 18, color: Color(0xFFc4b5fd)),
                  label: Text(
                    'Use demo credentials',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFFe9d5ff),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFe9d5ff),
                    side: const BorderSide(color: Color(0xFF6d28d9)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    backgroundColor: const Color(0xFF1a1033),
                  ),
                ),
                const SizedBox(height: 20),

                // Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF13132a),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  padding: EdgeInsets.all(compact ? 20 : 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign in to your account',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use your hospital credentials',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email
                        _label('Email address'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: _inputDecoration('doctor@hospital.com', Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _label('Password'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: _inputDecoration('••••••••', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: const Color(0xFF6b7280),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password too short';
                            return null;
                          },
                          onFieldSubmitted: (_) => _signIn(),
                        ),
                        const SizedBox(height: 28),

                        // Sign in button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7c3aed),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF4c1d95),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _loading ? null : _applyDemoCredentials,
                          child: Text(
                            'Fill demo login again',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFa78bfa),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Access restricted to authorised hospital staff only.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF4b5563),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFd1d5db),
        ),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF374151), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6b7280), size: 18),
        filled: true,
        fillColor: const Color(0xFF0d0d1a),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1e1e3a)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7c3aed), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFb91c1c)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFb91c1c), width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFf87171)),
      );
}
