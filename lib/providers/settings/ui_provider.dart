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
import 'package:shared_preferences/shared_preferences.dart';
import '../notes_provider.dart';
import '../tasks_provider.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';

/// Base for a StateNotifier whose enum value is persisted to
/// SharedPreferences by *name* rather than index, so a future reordering or
/// removal of enum values can't make a stored preference point at the wrong
/// value (or throw a RangeError) — every subclass persists on every `state =`
/// assignment automatically, so a new setting can't forget to save itself.
abstract class PersistedEnumNotifier<T extends Enum> extends StateNotifier<T> {
  PersistedEnumNotifier(this._prefs, this._key, this._values, T defaultValue)
    : super(defaultValue) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _key;
  final List<T> _values;

  void _load() {
    final name = _prefs.getString(_key);
    if (name == null) return;
    for (final v in _values) {
      if (v.name == name) {
        super.state = v;
        return;
      }
    }
    // Unknown/stale value (e.g. saved by a since-removed enum entry) — keep
    // the default instead of throwing.
  }

  @override
  set state(T val) {
    super.state = val;
    _prefs.setString(_key, val.name);
  }
}

// --- Home Layout ---

enum HomeLayout { grid, list }

const _kLayoutKey = 'home_layout_v2';

class HomeLayoutNotifier extends PersistedEnumNotifier<HomeLayout> {
  HomeLayoutNotifier(SharedPreferences prefs)
    : super(prefs, _kLayoutKey, HomeLayout.values, HomeLayout.grid);

  void toggle() {
    state = state == HomeLayout.grid ? HomeLayout.list : HomeLayout.grid;
  }
}

final homeLayoutProvider =
    StateNotifierProvider<HomeLayoutNotifier, HomeLayout>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return HomeLayoutNotifier(prefs);
    });

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
  SortOrderNotifier(SharedPreferences prefs)
    : super(prefs, _kSortKey, SortOrder.values, SortOrder.createdNewest);
}

final sortOrderProvider = StateNotifierProvider<SortOrderNotifier, SortOrder>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SortOrderNotifier(prefs);
});

// --- Task Sort Order ---

const _kTaskSortKey = 'task_sort_order_v2';

class TaskSortOrderNotifier extends PersistedEnumNotifier<SortOrder> {
  TaskSortOrderNotifier(SharedPreferences prefs)
    : super(prefs, _kTaskSortKey, SortOrder.values, SortOrder.createdNewest);
}

final taskSortOrderProvider =
    StateNotifierProvider<TaskSortOrderNotifier, SortOrder>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return TaskSortOrderNotifier(prefs);
    });

// --- Search & Filters ---

final searchQueryProvider = StateProvider<String>((ref) => '');
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

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

class CustomLabelsNotifier extends StateNotifier<List<String>> {
  CustomLabelsNotifier(this._prefs) : super([]) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    state = _prefs.getStringList(_kCustomLabelsKey) ?? [];
  }

  Future<void> _save() async {
    await _prefs.setStringList(_kCustomLabelsKey, state);
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
    StateNotifierProvider<CustomLabelsNotifier, List<String>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return CustomLabelsNotifier(prefs);
    });

// --- Task Settings ---

const _kShowCompletedTasksKey = 'show_completed_tasks';
const _kGroupTasksByPriorityKey = 'group_tasks_by_priority';

final showCompletedTasksProvider =
    StateNotifierProvider<_BoolSettingNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return _BoolSettingNotifier(prefs, _kShowCompletedTasksKey, true);
    });

final groupTasksByPriorityProvider =
    StateNotifierProvider<_BoolSettingNotifier, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return _BoolSettingNotifier(prefs, _kGroupTasksByPriorityKey, true);
    });

class _BoolSettingNotifier extends StateNotifier<bool> {
  _BoolSettingNotifier(this._prefs, this._key, bool defaultValue)
    : super(defaultValue) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _key;

  void _load() {
    final value = _prefs.getBool(_key);
    if (value != null) state = value;
  }

  void toggle() {
    state = !state;
    _prefs.setBool(_key, state);
  }

  @override
  set state(bool val) {
    super.state = val;
    _prefs.setBool(_key, val);
  }
}
