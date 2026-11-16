import 'package:flutter/material.dart';

import '../config/media.dart';
import '../data/library_repository.dart';
import '../theme.dart';
import '../widgets/video_box.dart';
import 'home_shell.dart';

/// Video pembuka yang tampil sekali setelah login berhasil.
class IntroVideoScreen extends StatefulWidget {
  final LibraryRepository repo;
  const IntroVideoScreen({super.key, required this.repo});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    if (introVideoPath.isEmpty) {
      Future.delayed(const Duration(seconds: 2), _enter);
    }
  }

  void _enter() {
    if (_entered || !mounted) return;
    _entered = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeShell(repo: widget.repo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _enter,
                child: const Text('Lewati', style: TextStyle(color: MarsColors.muted)),
              ),
            ),
            Expanded(
              child: Center(
                child: introVideoPath.isEmpty
                    ? const Text('Video pembuka belum diatur',
                        style: TextStyle(color: MarsColors.muted))
                    : VideoBox(path: introVideoPath, onCompleted: _enter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
