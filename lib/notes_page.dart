import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';
import 'package:notes_app/note_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final textController = TextEditingController();
  final _noteDatabase = NoteDatabase();
  String searchQuery = "";

  // Filter by Favorite
  bool isFilteredByFavorite = false;

  // Checkbox state for new note favorite
  bool isFavoriteNewNote = false;

  // Checkbox state for editing note favorite
  bool isFavoriteEditNote = false; // Tambahan baru untuk checkbox saat mengedit

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update query pencarian
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _noteDatabase.getNotesStream(),
        builder: (context, snapshot) {
          // loading ...
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // loaded
          final notes = snapshot.data!;

          // Filter catatan berdasarkan query pencarian
          final searchedNotes = notes
              .where((note) =>
                  note.content.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          // List of notes
          return ListView.builder(
            itemCount: searchedNotes.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(searchedNotes[index].content),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editNote(searchedNotes[index]),
                      icon: const Icon(Icons.edit, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () => deleteNote(searchedNotes[index]),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
              leading: searchedNotes[index].isFavorite
                  ? GestureDetector(
                      onTap: () => toggleFavorite(searchedNotes[index]),
                      child: const Icon(
                        Icons.star,
                        color: Colors.orange,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => toggleFavorite(searchedNotes[index]),
                      child: const Icon(Icons.star_border)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter note content',
              ),
            ),
            Row(
              children: [
                const Text('Mark as Favorite:'),
                Checkbox(
                  value: isFavoriteNewNote,
                  onChanged: (value) {
                    setState(() {
                      isFavoriteNewNote = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Create a new note
              final note = Note(
                content: textController.text,
                isFavorite: isFavoriteNewNote,
              );

              // Save the note to the database
              _noteDatabase.insertNote(note);

              // Reset states and close the dialog
              Navigator.pop(context);
              textController.clear();
              setState(() {
                isFavoriteNewNote = false;
              });
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  // Edit a note
  void editNote(Note note) {
    textController.text = note.content;
    isFavoriteEditNote = note.isFavorite; // Mengambil status favorit dari catatan

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter note content',
              ),
            ),
            Row(
              children: [
                const Text('Mark as Favorite:'),
                Checkbox(
                  value: isFavoriteEditNote,
                  onChanged: (value) {
                    setState(() {
                      isFavoriteEditNote = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              note.content = textController.text; // Update konten catatan
              note.isFavorite = isFavoriteEditNote; // Update status favorit
              _noteDatabase.updateNote(note);

              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete a note
  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: Text(
                      'This action cannot be undone.\n\n"${note.content}"'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _noteDatabase.deleteNote(note.id!);
                        Navigator.pop(context);
                      },
                      child: const Text('Yes, Delete'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void toggleFavorite(Note note) {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
  }

  void saveNote() async {
    await Supabase.instance.client.from('notes').insert({
      'body': textController.text,
    });
    textController.clear();
  }
}
