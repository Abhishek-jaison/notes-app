import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drivenotes/features/auth/presentation/providers/auth_provider.dart';
import 'package:drivenotes/features/notes/presentation/providers/notes_provider.dart';
import 'package:drivenotes/features/notes/domain/entities/note.dart';
import 'package:drivenotes/core/providers/theme_provider.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              key: ValueKey(isDarkMode),
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode ? Colors.amber : Colors.black87,
              ),
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        Icons.note_add,
                        key: const ValueKey('empty_icon'),
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        key: const ValueKey('empty_text'),
                        'No notes yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        key: const ValueKey('empty_hint'),
                        'Tap the + button to create your first note',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ListView.builder(
                key: ValueKey(notes.length),
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Dismissible(
                    key: Key(note.id),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      ref.read(notesProvider.notifier).deleteNote(note.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Note deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              ref
                                  .read(notesProvider.notifier)
                                  .createNote(note.title, note.content);
                            },
                          ),
                        ),
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        key: ValueKey(note.id),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          onTap:
                              () => context.push(
                                '/notes/${note.id}',
                                extra: note,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Icon(
                        key: ValueKey(error),
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        key: ValueKey(error),
                        'Error: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notes/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}
