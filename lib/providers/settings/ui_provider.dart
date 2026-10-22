// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core_providers.dart';
import '../notes_provider.dart';
import '../tasks_provider.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';

/// Base for a Notifier whose enum value is persisted to SharedPreferences by
/// *name* rather than index, so a future reordering or removal of enum
/// values can't make a stored preference point at the wrong value (or throw
/// a RangeError). Every change goes through [set], which also saves it, so a
/// new setting can't forget to save itself.
abstract class PersistedEnumNotifier<T extends Enum> extends Notifier<T> {
  PersistedEnumNotifier(this._key, this._values, this._defaultValue);

  final String _key;
  final List<T> _values;
  final T _defaultValue;

  @override
  T build() {
    final name = ref.watch(sharedPreferencesProvider).getString(_key);
    for (final v in _values) {
      if (v.name == name) return v;
    }
    // Missing or stale value (e.g. saved by a since-removed enum entry) —
    // keep the default instead of throwing.
    return _defaultValue;
  }

  void set(T value) {
    state = value;
    ref.read(sharedPreferencesProvider).setString(_key, value.name);
  }
}

// --- Home Layout ---

enum HomeLayout { grid, list }

const _kLayoutKey = 'home_layout_v2';

class HomeLayoutNotifier extends PersistedEnumNotifier<HomeLayout> {
  HomeLayoutNotifier() : super(_kLayoutKey, HomeLayout.values, HomeLayout.grid);

  void toggle() =>
      set(state == HomeLayout.grid ? HomeLayout.list : HomeLayout.grid);
}

final homeLayoutProvider = NotifierProvider<HomeLayoutNotifier, HomeLayout>(
  HomeLayoutNotifier.new,
);

// --- Sort Order ---

enum SortOrder {
  custom,
  createdNewest,
  createdOldest,
  modifiedNewest,
  modifiedOldest,
}

const _kSortKey = 'sort_order_v2';

class SortOrderNotifier extends PersistedEnumNotifier<SortOrder> {
  SortOrderNotifier()
    : super(_kSortKey, SortOrder.values, SortOrder.createdNewest);
}

final sortOrderProvider = NotifierProvider<SortOrderNotifier, SortOrder>(
  SortOrderNotifier.new,
);

// --- Task Sort Order ---

const _kTaskSortKey = 'task_sort_order_v2';

class TaskSortOrderNotifier extends PersistedEnumNotifier<SortOrder> {
  TaskSortOrderNotifier()
    : super(_kTaskSortKey, SortOrder.values, SortOrder.createdNewest);
}

final taskSortOrderProvider =
    NotifierProvider<TaskSortOrderNotifier, SortOrder>(
      TaskSortOrderNotifier.new,
    );

// --- Search & Filters ---

final searchQueryProvider = valueStateProvider<String>('');
final taskSearchQueryProvider = valueStateProvider<String>('');

final filteredNotesProvider = Provider<List<NoteModel>>((ref) {
  final notes = ref.watch(activeNotesProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sort = ref.watch(sortOrderProvider);

  var filtered = notes;
  if (query.isNotEmpty) {
    filtered =
        filtered.where((n) {
          return n.title.toLowerCase().contains(query) ||
              (!n.isLocked && n.content.toLowerCase().contains(query));
        }).toList();
  }

  switch (sort) {
    case SortOrder.createdNewest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOrder.createdOldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOrder.modifiedNewest:
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case SortOrder.modifiedOldest:
      filtered.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      break;
    case SortOrder.custom:
      // Mantieni l'ordine dello state
      break;
  }

  return filtered;
});

/// Ids of [filteredNotesProvider], in display order: the Home screen watches
/// this, so editing a note's content (without changing which notes match or
/// their order) only rebuilds that note's card.
final filteredNoteIdsProvider = Provider<IdList>((ref) {
  return IdList(ref.watch(filteredNotesProvider).map((n) => n.id));
});

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(activeTasksProvider);
  final query = ref.watch(taskSearchQueryProvider).toLowerCase();

  if (query.isEmpty) return tasks;
  return tasks.where((t) {
    return t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query);
  }).toList();
});

final allTagsProvider = Provider<List<String>>((ref) {
  final notes = ref.watch(notesProvider);
  final customLabels = ref.watch(customLabelsProvider);
  final tags = <String>{};
  for (final n in notes) {
    tags.addAll(n.tags);
  }
  tags.addAll(customLabels);
  return tags.toList()..sort();
});

// --- Custom Labels (standalone, not tied to any note) ---

const _kCustomLabelsKey = 'custom_labels';

class CustomLabelsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() =>
      ref.watch(sharedPreferencesProvider).getStringList(_kCustomLabelsKey) ??
      [];

  Future<void> _save() async {
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_kCustomLabelsKey, state);
  }

  void addLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || state.contains(trimmed)) return;
    state = [...state, trimmed];
    _save();
  }

  void renameLabel(String oldLabel, String newLabel) {
    final trimmed = newLabel.trim();
    if (!state.contains(oldLabel) || trimmed.isEmpty) return;
    state = state.map((l) => l == oldLabel ? trimmed : l).toList();
    _save();
  }

  void deleteLabel(String label) {
    state = state.where((l) => l != label).toList();
    _save();
  }
}

final customLabelsProvider =
    NotifierProvider<CustomLabelsNotifier, List<String>>(
      CustomLabelsNotifier.new,
    );

// --- Task Settings ---

const _kShowCompletedTasksKey = 'show_completed_tasks';
const _kGroupTasksByPriorityKey = 'group_tasks_by_priority';

final showCompletedTasksProvider = NotifierProvider<BoolSettingNotifier, bool>(
  () => BoolSettingNotifier(_kShowCompletedTasksKey, true),
);

final groupTasksByPriorityProvider =
    NotifierProvider<BoolSettingNotifier, bool>(
      () => BoolSettingNotifier(_kGroupTasksByPriorityKey, true),
    );

// --- Onboarding ---

const _kOnboardingSeenKey = 'onboarding_seen';

/// Whether the first-launch introduction has been completed or skipped.
final onboardingSeenProvider = NotifierProvider<BoolSettingNotifier, bool>(
  () => BoolSettingNotifier(_kOnboardingSeenKey, false),
);

/// A boolean preference persisted to SharedPreferences under its key.
class BoolSettingNotifier extends Notifier<bool> {
  BoolSettingNotifier(this._key, this._defaultValue);

  final String _key;
  final bool _defaultValue;

  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(_key) ?? _defaultValue;

  void toggle() => set(!state);

  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider).setBool(_key, value);
  }
}
