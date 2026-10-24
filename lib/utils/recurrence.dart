// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../l10n/app_localizations.dart';

enum RecurrenceType {
  none, // No recurrence
  daily, // Repeats every day
  weekly, // Repeats every week
  monthly, // Repeats every month
  yearly, // Repeats every year
}

RecurrenceType recurrenceTypeFromString(String value) {
  try {
    return RecurrenceType.values.firstWhere(
      (e) => e.toString() == 'RecurrenceType.$value',
    );
  } catch (_) {
    return RecurrenceType.none;
  }
}

extension RecurrenceTypeExtension on RecurrenceType {
  String label(AppLocalizations l) {
    switch (this) {
      case RecurrenceType.none:
        return l.eventRecurrenceNone;
      case RecurrenceType.daily:
        return l.eventRecurrenceDaily;
      case RecurrenceType.weekly:
        return l.eventRecurrenceWeekly;
      case RecurrenceType.monthly:
        return l.eventRecurrenceMonthly;
      case RecurrenceType.yearly:
        return l.eventRecurrenceYearly;
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }
}
