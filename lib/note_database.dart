import 'package:notes_app/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDatabase {
	// Instantiate new database object
  final database = Supabase.instance.client.from('notes');

  // Insert a note into the database
  Future<void> insertNote(Note note) async {
    await database.insert(note.toJson());
  }

  // Get a stream of notes from the database
  Stream<List<Note>> getNotesStream() {
    return database.stream(primaryKey: ['id']).map(
        (data) => data.map((json) => Note.fromJson(json)).toList());
  }

  // Delete a note from the database
  Future<void> deleteNote(int id) async {
    await database.delete().eq('id', id);
  }

  // Update a note in the database
  Future<void> updateNote(Note note) async {
    await database.update(note.toJson()).eq('id', note.id!);
  }
}