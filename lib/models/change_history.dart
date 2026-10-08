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
