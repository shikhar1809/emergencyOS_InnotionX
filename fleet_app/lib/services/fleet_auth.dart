class FleetAuth {
  static final _fleetEmailRe = RegExp(r'^(fleet(\d+))@.+\.goelhospital\.com$', caseSensitive: false);

  static bool validate(String emailRaw, String password) {
    final email = emailRaw.trim().toLowerCase();
    final m = _fleetEmailRe.firstMatch(email);
    if (m == null) return false;
    final nStr = m.group(2);
    if (nStr == null) return false;
    final n = int.tryParse(nStr);
    if (n == null) return false;

    // Admin panel generates password GH@(1000 + n). We also accept GH@n for compatibility.
    return password == 'GH@${1000 + n}' || password == 'GH@$n';
  }

  static String displayNameFromEmail(String emailRaw) {
    final email = emailRaw.trim().toLowerCase();
    final at = email.indexOf('@');
    if (at <= 0) return 'Fleet Operator';
    final domainPart = email.substring(at + 1);
    final firstDot = domainPart.indexOf('.');
    final alias = firstDot > 0 ? domainPart.substring(0, firstDot) : domainPart;
    if (alias.isEmpty) return 'Fleet Operator';
    return '${alias[0].toUpperCase()}${alias.substring(1)} (Fleet)';
  }
}

