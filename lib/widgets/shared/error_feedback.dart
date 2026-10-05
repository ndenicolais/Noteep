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

const _kErrorMessage = 'Si è verificato un errore. Riprova.';

/// Shows [message] with an "Annulla" action that runs [onUndo], for
/// reversible fire-and-forget mutations (trash, archive). If [future] fails
/// the undo SnackBar is replaced by an error one, since the notifier has
/// already rolled the change back.
///
/// The messenger is captured up front, so this also works when the caller
/// pops its route right after (e.g. deleting from an editor): the SnackBar
/// then appears on the screen underneath.
void notifyWithUndo(
  Future<void> future,
  BuildContext context, {
  required String message,
  required Future<void> Function() onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context);
  void showError() {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(_kErrorMessage)));
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        persist: false,
        action: SnackBarAction(
          label: 'Annulla',
          onPressed: () => onUndo().catchError((_) => showError()),
        ),
      ),
    );
  future.catchError((_) => showError());
}

/// Attaches a SnackBar error handler to a fire-and-forget persistence
/// [Future] (e.g. a Firestore write from a `StateNotifier` mutation), so a
/// failure surfaces to the user instead of disappearing as an unhandled
/// exception. Safe to call even if [context] is unmounted by the time the
/// future settles.
void notifyOnError(
  Future<void> future,
  BuildContext context, {
  String message = _kErrorMessage,
}) {
  future.catchError((_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  });
}
