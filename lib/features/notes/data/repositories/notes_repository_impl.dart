import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:drivenotes/features/notes/domain/entities/note.dart';
import 'package:drivenotes/features/notes/domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final _storage = const FlutterSecureStorage();
  static const _folderName = 'DriveNotes';
  drive.DriveApi? _driveApi;
  String? _folderId;

  Future<drive.DriveApi> _getDriveApi() async {
    if (_driveApi != null) return _driveApi!;

    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }

    final client = http.Client();
    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      null, // No refresh token needed
      ['https://www.googleapis.com/auth/drive.file'],
    );

    final authClient = auth.authenticatedClient(client, credentials);
    _driveApi = drive.DriveApi(authClient);
    return _driveApi!;
  }

  Future<String> _getFolderId() async {
    if (_folderId != null) return _folderId!;

    final driveApi = await _getDriveApi();
    final response = await driveApi.files.list(
      q: "name = '$_folderName' and mimeType = 'application/vnd.google-apps.folder'",
      spaces: 'drive',
    );

    if (response.files?.isEmpty ?? true) {
      // Create folder if it doesn't exist
      final folder =
          drive.File()
            ..name = _folderName
            ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      _folderId = createdFolder.id!;
    } else {
      _folderId = response.files!.first.id!;
    }

    return _folderId!;
  }

  @override
  Future<List<Note>> getNotes() async {
    try {
      final driveApi = await _getDriveApi();
      final folderId = await _getFolderId();

      final response = await driveApi.files.list(
        q: "'$folderId' in parents and mimeType = 'text/plain'",
        spaces: 'drive',
        orderBy: 'modifiedTime desc',
      );

      final notes = <Note>[];
      for (final file in response.files ?? []) {
        if (file.id == null) continue;

        final content =
            await driveApi.files.get(
                  file.id!,
                  downloadOptions: drive.DownloadOptions.fullMedia,
                )
                as drive.Media;

        final noteContent = await utf8.decodeStream(content.stream);
        final noteData = json.decode(noteContent);

        notes.add(Note.fromJson(noteData));
      }

      return notes;
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  @override
  Future<Note> createNote(String title, String content) async {
    final driveApi = await _getDriveApi();
    final folderId = await _getFolderId();

    final note = Note(
      id: DateTime.now().toIso8601String(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final noteJson = json.encode(note.toJson());
    final stream = Stream.value(utf8.encode(noteJson));
    final media = drive.Media(stream, noteJson.length);

    final driveFile =
        drive.File()
          ..name = '${note.id}.txt'
          ..parents = [folderId]
          ..mimeType = 'text/plain';

    final response = await driveApi.files.create(driveFile, uploadMedia: media);

    return note.copyWith(driveFileId: response.id);
  }

  @override
  Future<Note> updateNote(Note note) async {
    if (note.driveFileId == null) {
      throw Exception('Note not found in Drive');
    }

    final driveApi = await _getDriveApi();
    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    final noteJson = json.encode(updatedNote.toJson());
    final stream = Stream.value(utf8.encode(noteJson));
    final media = drive.Media(stream, noteJson.length);

    await driveApi.files.update(
      drive.File(),
      note.driveFileId!,
      uploadMedia: media,
    );

    return updatedNote;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final driveApi = await _getDriveApi();
    final folderId = await _getFolderId();

    final response = await driveApi.files.list(
      q: "'$folderId' in parents and name = '$noteId.txt'",
      spaces: 'drive',
    );

    if (response.files?.isNotEmpty ?? false) {
      await driveApi.files.delete(response.files!.first.id!);
    }
  }
}
