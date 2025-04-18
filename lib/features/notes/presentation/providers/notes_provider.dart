import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/features/notes/domain/entities/note.dart';
import 'package:drivenotes/features/notes/domain/repositories/notes_repository.dart';

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NotesRepository _repository;

  @override
  Future<List<Note>> build() async {
    _repository = ref.watch(notesRepositoryProvider);
    return _repository.getNotes();
  }

  Future<void> createNote(String title, String content) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repository.createNote(title, content);
      state = AsyncValue.data([...state.value ?? [], note]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final updatedNote = await _repository.updateNote(note);
      state = AsyncValue.data(
        state.value?.map((n) => n.id == note.id ? updatedNote : n).toList() ??
            [],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteNote(noteId);
      state = AsyncValue.data(
        state.value?.where((note) => note.id != noteId).toList() ?? [],
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
