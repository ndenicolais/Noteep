// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/changelog.dart';

const _kLastSeenChangelogVersionKey = 'last_seen_changelog_version';

/// Decides which changelog entries to show after an update.
class ChangelogService {
  /// Returns the entries newer than the version the user last saw and
  /// records [currentVersion] as seen.
  ///
  /// On a fresh install nothing is shown: the current version is only
  /// recorded, so the dialog appears from the next update on.
  static Future<List<ChangelogEntry>> pendingEntries(
    SharedPreferences prefs,
    String currentVersion, {
    List<ChangelogEntry> entries = changelogEntries,
  }) async {
    final lastSeen = prefs.getString(_kLastSeenChangelogVersionKey);

    if (lastSeen == currentVersion) return const [];
    await prefs.setString(_kLastSeenChangelogVersionKey, currentVersion);
    if (lastSeen == null) return const [];

    final lastSeenIndex = entries.indexWhere((e) => e.version == lastSeen);
    return lastSeenIndex == -1 ? entries : entries.sublist(0, lastSeenIndex);
  }
}
