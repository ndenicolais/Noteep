// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Time first offered by a time picker for [date]: [preferred], unless
/// [date] is today and [preferred] has already passed, then the current
/// time (creating something at 11:30 for today starts from 11:30, not
/// from the default 09:00).
TimeOfDay initialPickerTime(DateTime date, TimeOfDay preferred) {
  if (!_isToday(date)) return preferred;
  final now = TimeOfDay.now();
  final passed =
      preferred.hour < now.hour ||
      (preferred.hour == now.hour && preferred.minute < now.minute);
  return passed ? now : preferred;
}

/// Start of a new entry created on [day]: now when [day] is today, the
/// day itself otherwise.
DateTime newEntryStart(DateTime day) => _isToday(day) ? DateTime.now() : day;
