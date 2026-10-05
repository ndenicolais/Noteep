// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';

/// Attaches a SnackBar error handler to a fire-and-forget persistence
/// [Future] (e.g. a Firestore write from a `StateNotifier` mutation), so a
/// failure surfaces to the user instead of disappearing as an unhandled
/// exception. Safe to call even if [context] is unmounted by the time the
/// future settles.
void notifyOnError(
  Future<void> future,
  BuildContext context, {
  String message = 'Si è verificato un errore. Riprova.',
}) {
  future.catchError((_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  });
}
