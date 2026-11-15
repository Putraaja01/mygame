import 'package:flutter/material.dart';

import 'data/library_repository.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = LibraryRepository();
  await repo.init();
  runApp(GameLibraryApp(repo: repo));
}

class GameLibraryApp extends StatelessWidget {
  final LibraryRepository repo;
  const GameLibraryApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: LoginScreen(repo: repo),
    );
  }
}