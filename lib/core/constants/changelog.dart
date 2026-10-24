// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../l10n/l10n.dart';

/// Kind of change, used to group the bullets of a version into sections.
/// The enum order is the order of the sections in the dialog.
enum ChangeType { added, improved, fixed, security }

class ChangelogItem {
  const ChangelogItem(this.type, this.textBuilder);

  final ChangeType type;

  /// A function of the strings, not a plain string, so [changelogEntries]
  /// needs no BuildContext and the dialog always shows the current language.
  final String Function(AppLocalizations l) textBuilder;
}

class ChangelogEntry {
  const ChangelogEntry({required this.version, required this.items});

  final String version;
  final List<ChangelogItem> items;

  /// Items grouped by [ChangeType] in enum order; empty types are omitted.
  Map<ChangeType, List<ChangelogItem>> get sections => {
    for (final type in ChangeType.values)
      if (items.any((item) => item.type == type))
        type: items.where((item) => item.type == type).toList(),
  };
}

/// Newest version first. Bullet texts are the `changelog_v<version>_bullet_N`
/// keys of `lib/l10n/app_*.arb`.
final List<ChangelogEntry> changelogEntries = [
  ChangelogEntry(
    version: '2.0.0',
    items: [
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_1),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_2),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_3),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_4),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_5),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_6),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_7),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_8),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_9),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_10),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_11),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_12),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_13),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_14),
      ChangelogItem(ChangeType.fixed, (l) => l.changelog_v2_0_0_bullet_15),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_16),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_17),
      ChangelogItem(ChangeType.fixed, (l) => l.changelog_v2_0_0_bullet_18),
      ChangelogItem(ChangeType.fixed, (l) => l.changelog_v2_0_0_bullet_19),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_20),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_21),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_22),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_23),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_24),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_25),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_26),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_27),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_28),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_29),
      ChangelogItem(ChangeType.security, (l) => l.changelog_v2_0_0_bullet_30),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_31),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_32),
      ChangelogItem(ChangeType.fixed, (l) => l.changelog_v2_0_0_bullet_33),
      ChangelogItem(ChangeType.added, (l) => l.changelog_v2_0_0_bullet_34),
      ChangelogItem(ChangeType.improved, (l) => l.changelog_v2_0_0_bullet_35),
    ],
  ),
];
