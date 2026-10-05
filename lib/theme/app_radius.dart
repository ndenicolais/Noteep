// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

/// Central corner-radius scale for the app, so cards/sheets/tiles across
/// screens share the same set of values instead of scattered magic numbers.
class AppRadius {
  AppRadius._();

  static const double sm = 8.0; // list tiles inside sheets
  static const double md = 12.0; // cards
  static const double lg = 16.0; // small bottom sheets
  static const double xl = 20.0; // full-height bottom sheets / dialogs
}
