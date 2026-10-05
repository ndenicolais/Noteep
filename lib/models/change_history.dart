// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../models/note_model.dart';
import '../models/audio_note.dart';

abstract class NoteChange {
  NoteModel apply(NoteModel note);
  NoteModel undo(NoteModel note);
}

class NoteTextChange implements NoteChange {
  final String oldText;
  final String newText;

  NoteTextChange({required this.oldText, required this.newText});

  @override
  NoteModel apply(NoteModel note) {
    return note.copyWith(content: newText);
  }

  @override
  NoteModel undo(NoteModel note) {
    return note.copyWith(content: oldText);
  }
}

class NoteTitleChange implements NoteChange {
  final String oldTitle;
  final String newTitle;

  NoteTitleChange({required this.oldTitle, required this.newTitle});

  @override
  NoteModel apply(NoteModel note) {
    return note.copyWith(title: newTitle);
  }

  @override
  NoteModel undo(NoteModel note) {
    return note.copyWith(title: oldTitle);
  }
}

class NoteStyleChange implements NoteChange {
  final NoteStyle oldStyle;
  final NoteStyle newStyle;

  NoteStyleChange({required this.oldStyle, required this.newStyle});

  @override
  NoteModel apply(NoteModel note) {
    return note.copyWith(style: newStyle);
  }

  @override
  NoteModel undo(NoteModel note) {
    return note.copyWith(style: oldStyle);
  }
}

class ChecklistItemToggleChange implements NoteChange {
  final String itemId;
  final bool oldChecked;
  final bool newChecked;

  ChecklistItemToggleChange({
    required this.itemId,
    required this.oldChecked,
    required this.newChecked,
  });

  @override
  NoteModel apply(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    final items =
        note.checklistItems.map((item) {
          return item.id == itemId
              ? item.copyWith(isChecked: newChecked)
              : item;
        }).toList();
    return note.copyWith(checklistItems: items);
  }

  @override
  NoteModel undo(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    final items =
        note.checklistItems.map((item) {
          return item.id == itemId
              ? item.copyWith(isChecked: oldChecked)
              : item;
        }).toList();
    return note.copyWith(checklistItems: items);
  }
}

class ChecklistItemAddChange implements NoteChange {
  final ChecklistItem item;

  ChecklistItemAddChange({required this.item});

  @override
  NoteModel apply(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    return note.copyWith(checklistItems: [...note.checklistItems, item]);
  }

  @override
  NoteModel undo(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    final items = note.checklistItems.where((i) => i.id != item.id).toList();
    return note.copyWith(checklistItems: items);
  }
}

class ChecklistItemDeleteChange implements NoteChange {
  final ChecklistItem item;
  final int index;

  ChecklistItemDeleteChange({required this.item, required this.index});

  @override
  NoteModel apply(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    final items = note.checklistItems.where((i) => i.id != item.id).toList();
    return note.copyWith(checklistItems: items);
  }

  @override
  NoteModel undo(NoteModel note) {
    if (note.type != NoteType.checklist) return note;
    final items = [...note.checklistItems];
    items.insert(index, item);
    return note.copyWith(checklistItems: items);
  }
}

class AudioNoteAddChange implements NoteChange {
  final AudioNote audio;

  AudioNoteAddChange({required this.audio});

  @override
  NoteModel apply(NoteModel note) {
    return note.copyWith(audioNotes: [...note.audioNotes, audio]);
  }

  @override
  NoteModel undo(NoteModel note) {
    final audioNotes = note.audioNotes.where((a) => a.id != audio.id).toList();
    return note.copyWith(audioNotes: audioNotes);
  }
}

class AudioNoteDeleteChange implements NoteChange {
  final AudioNote audio;
  final int index;

  AudioNoteDeleteChange({required this.audio, required this.index});

  @override
  NoteModel apply(NoteModel note) {
    final audioNotes = note.audioNotes.where((a) => a.id != audio.id).toList();
    return note.copyWith(audioNotes: audioNotes);
  }

  @override
  NoteModel undo(NoteModel note) {
    final audioNotes = [...note.audioNotes];
    audioNotes.insert(index, audio);
    return note.copyWith(audioNotes: audioNotes);
  }
}
