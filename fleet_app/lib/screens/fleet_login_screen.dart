import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/fleet_auth.dart';
import '../services/fleet_storage.dart';

/// Staff-portal–inspired auth layout with blue accents (replacing purple).
class FleetLoginScreen extends StatefulWidget {
  const FleetLoginScreen({super.key});

  @override
  State<FleetLoginScreen> createState() => _FleetLoginScreenState();
}

class _FleetLoginScreenState extends State<FleetLoginScreen> {
  static const _bg = Color(0xFF0d0d1a);
  static const _card = Color(0xFF13132a);
  static const _cardBorder = Color(0xFF1e1e3a);
  static const _inputFill = Color(0xFF0d0d1a);
  static const _muted = Color(0xFF6b7280);
  static const _label = Color(0xFFd1d5db);
  static const _primaryBlue = Color(0xFF2563EB);
  static const _primaryBlueDark = Color(0xFF1d4ed8);

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _invalid = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _invalid = false;
    });

    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    await Future<void>.delayed(Duration.zero);

    if (!mounted) return;

    if (!FleetAuth.validate(email, pass)) {
      setState(() {
        _invalid = true;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = false);
    FleetStorage.setSessionEmail(email);
  }

  void _demo() {
    _emailCtrl.text = 'fleet4@driver.goelhospital.com';
    _passCtrl.text = 'GH@1004';
    _signIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo — rounded square, blue gradient + glow (staff uses purple)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primaryBlue, _primaryBlueDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  'EmergencyOS',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fleet Portal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9ca3af),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Card
                Container(
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  padding: const EdgeInsets.all(28),
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
                          'Use your fleet credentials from hospital admin',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (_invalid) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7f1d1d),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFb91c1c)),
                            ),
                            child: Text(
                              'Invalid credentials. Use fleet credentials from admin panel.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFFfecaca),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        _fieldLabel('Email address'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: _inputDecoration(
                            'fleet4@driver.goelhospital.com',
                            Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _fieldLabel('Password'),
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
                            return null;
                          },
                          onFieldSubmitted: (_) => _signIn(),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF1e3a5f),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _loading ? null : _demo,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF9ca3af),
                              side: const BorderSide(color: _cardBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Use demo credentials',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Access restricted to authorised fleet operators only.',
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
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _label,
        ),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF374151), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF6b7280), size: 18),
        filled: true,
        fillColor: _inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
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
