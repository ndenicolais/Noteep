import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:noteep/models/note_model.dart';

class NotesService {
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function that get Notes collection reference for current user
  CollectionReference getNotesCollection() {
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes');
  }

  // Function that adds a new Note to Firestore
  Future<String> addNote(NoteModel note) async {
    try {
      CollectionReference notesCollection = getNotesCollection();
      DocumentReference docRef = await notesCollection.add(note.toMap());
      _logger.i("Note added successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      _logger.e("Error adding the Note: $e");
      rethrow;
    }
  }

  // Function that updates an existing Note in Firestore
  Future<void> updateNote(NoteModel note) async {
    try {
      CollectionReference notesCollection = getNotesCollection();
      await notesCollection.doc(note.id).update(note.toMap());
      _logger.i("Note updated successfully with ID: ${note.id}");
    } catch (e) {
      _logger.e("Error updating the Note: $e");
      rethrow;
    }
  }

  // Function that deletes a Note from Firestore
  Future<void> deleteNoteById(String noteId) async {
    try {
      CollectionReference notesCollection = getNotesCollection();
      await notesCollection.doc(noteId).delete();
      _logger.i("Note deleted successfully with ID: $noteId");
    } catch (e) {
      _logger.e("Error deleting the Note: $e");
      rethrow;
    }
  }

  // Function that provides a stream of Notes from Firestore
  Stream<List<NoteModel>> get notesStream {
    try {
      CollectionReference notesCollection = getNotesCollection();
      return notesCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return NoteModel.fromDocument(doc);
        }).toList();
      });
    } catch (e) {
      _logger.e("Error getting notes stream: $e");
      rethrow;
    }
  }

  // Function that retrieves a Note from Firestore by its ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      CollectionReference notesCollection = getNotesCollection();
      DocumentSnapshot docSnapshot = await notesCollection.doc(noteId).get();
      if (docSnapshot.exists) {
        _logger.i("Note retrieved successfully with ID: $noteId");
        return NoteModel.fromDocument(docSnapshot);
      } else {
        _logger.w("Note with ID: $noteId does not exist");
        return null;
      }
    } catch (e) {
      _logger.e("Error retrieving the Note: $e");
      rethrow;
    }
  }
}
