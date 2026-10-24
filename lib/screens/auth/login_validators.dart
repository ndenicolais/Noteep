// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import '../../l10n/l10n.dart';

final _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');

/// Form validators for the login/register/reset-password fields: `null` when
/// valid, otherwise the message shown under the field.
String? validateEmail(AppLocalizations l, String? v) {
  if (v == null || v.trim().isEmpty) return l.validationEmailEmpty;
  if (!_emailPattern.hasMatch(v.trim())) return l.validationEmailInvalid;
  return null;
}

String? validatePassword(AppLocalizations l, String? v) {
  if (v == null || v.isEmpty) return l.validationPasswordEmpty;
  if (v.length < 6) return l.validationPasswordTooShort;
  return null;
}

String? validatePasswordConfirmation(
  AppLocalizations l,
  String? v,
  String password,
) {
  if (v != password) return l.validationPasswordMismatch;
  return null;
}
