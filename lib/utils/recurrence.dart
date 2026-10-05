// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

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
  String get label {
    switch (this) {
      case RecurrenceType.none:
        return 'Non ripetere';
      case RecurrenceType.daily:
        return 'Giornalmente';
      case RecurrenceType.weekly:
        return 'Settimanalmente';
      case RecurrenceType.monthly:
        return 'Mensilmente';
      case RecurrenceType.yearly:
        return 'Annualmente';
    }
  }

  String get shortLabel {
    switch (this) {
      case RecurrenceType.none:
        return '';
      case RecurrenceType.daily:
        return 'Giorn.';
      case RecurrenceType.weekly:
        return 'Sett.';
      case RecurrenceType.monthly:
        return 'Mens.';
      case RecurrenceType.yearly:
        return 'Ann.';
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }
}
