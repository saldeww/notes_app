import 'package:flutter/material.dart';
import 'package:notes_app/notes_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Supabase Setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '',
    anonKey: '',
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotesPage(),
    );
  }
}
