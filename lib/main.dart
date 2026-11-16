import 'package:flutter/material.dart';

import 'data/library_repository.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = LibraryRepository();
  await repo.init();
  runApp(MarsProjekApp(repo: repo));
}

class MarsProjekApp extends StatelessWidget {
  final LibraryRepository repo;
  const MarsProjekApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mars Projek',
      debugShowCheckedModeBanner: false,
      theme: marsTheme(),
      home: LoginScreen(repo: repo),
    );
  }
}
