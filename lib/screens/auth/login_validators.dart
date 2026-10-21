// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');

/// Form validators for the login/register/reset-password fields: `null` when
/// valid, otherwise the message shown under the field.
String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Inserisci la tua email.';
  if (!_emailPattern.hasMatch(v.trim())) return 'Formato email non valido.';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Inserisci la password.';
  if (v.length < 6) return 'Minimo 6 caratteri.';
  return null;
}

String? validatePasswordConfirmation(String? v, String password) {
  if (v != password) return 'Le password non coincidono.';
  return null;
}
