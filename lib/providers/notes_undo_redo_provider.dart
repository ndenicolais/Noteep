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
import 'package:noteep/models/note_model.dart';
import '../models/change_history.dart';
import 'notes_provider.dart';

class NoteHistoryState {
  final bool canUndo;
  final bool canRedo;
  const NoteHistoryState({required this.canUndo, required this.canRedo});
  static const empty = NoteHistoryState(canUndo: false, canRedo: false);
}

/// Provider to manage undo/redo history for a specific note.
/// `autoDispose` releases each note's history once no editor screen is
/// watching it anymore — without it, every note ever opened during a
/// session keeps its (up to 50-entry) undo/redo stack alive forever.
final noteChangeHistoryProvider = StateNotifierProvider.autoDispose
    .family<NoteChangeHistoryNotifier, NoteHistoryState, String>(
      (ref, noteId) => NoteChangeHistoryNotifier(),
    );

class NoteChangeHistoryNotifier extends StateNotifier<NoteHistoryState> {
  NoteChangeHistoryNotifier() : super(NoteHistoryState.empty);

  final List<NoteChange> _undoStack = [];
  final List<NoteChange> _redoStack = [];
  static const int _maxSize = 50;

  void addChange(NoteChange change) {
    _undoStack.add(change);
    _redoStack.clear();
    if (_undoStack.length > _maxSize) _undoStack.removeAt(0);
    _notify();
  }

  NoteChange? undo() {
    if (_undoStack.isEmpty) return null;
    final change = _undoStack.removeLast();
    _redoStack.add(change);
    _notify();
    return change;
  }

  NoteChange? redo() {
    if (_redoStack.isEmpty) return null;
    final change = _redoStack.removeLast();
    _undoStack.add(change);
    _notify();
    return change;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    _notify();
  }

  void _notify() {
    state = NoteHistoryState(
      canUndo: _undoStack.isNotEmpty,
      canRedo: _redoStack.isNotEmpty,
    );
  }
}

/// Provider to handle undo/redo operations for notes
class NoteUndoRedoManager {
  static NoteModel? performUndo(
    WidgetRef ref,
    String noteId,
    NoteModel currentNote,
  ) {
    final notifier = ref.read(noteChangeHistoryProvider(noteId).notifier);
    final change = notifier.undo();
    if (change == null) return null;
    final undoneNote = change.undo(currentNote);
    final notes = ref.read(notesProvider);
    if (notes.any((n) => n.id == noteId)) {
      ref.read(notesProvider.notifier).updateNote(undoneNote);
    }
    return undoneNote;
  }

  static NoteModel? performRedo(
    WidgetRef ref,
    String noteId,
    NoteModel currentNote,
  ) {
    final notifier = ref.read(noteChangeHistoryProvider(noteId).notifier);
    final change = notifier.redo();
    if (change == null) return null;
    final redoneNote = change.apply(currentNote);
    final notes = ref.read(notesProvider);
    if (notes.any((n) => n.id == noteId)) {
      ref.read(notesProvider.notifier).updateNote(redoneNote);
    }
    return redoneNote;
  }
}
