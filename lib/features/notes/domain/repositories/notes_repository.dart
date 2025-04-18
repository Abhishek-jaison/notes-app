import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/features/notes/domain/entities/note.dart';
import 'package:drivenotes/features/notes/data/repositories/notes_repository_impl.dart';

abstract class NotesRepository {
  Future<List<Note>> getNotes();
  Future<Note> createNote(String title, String content);
  Future<Note> updateNote(Note note);
  Future<void> deleteNote(String noteId);
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepositoryImpl();
});
