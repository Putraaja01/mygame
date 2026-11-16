import 'package:flutter/material.dart';

import '../config/media.dart';
import '../data/library_repository.dart';
import '../models/quiz.dart';
import '../theme.dart';
import '../widgets/video_box.dart';
import 'quiz_play_screen.dart';

class BerandaScreen extends StatefulWidget {
  final LibraryRepository repo;
  const BerandaScreen({super.key, required this.repo});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  String _query = '';

  List<QuizGame> get _filtered {
    final q = _query.toLowerCase();
    return widget.repo.games
        .where((g) =>
            g.title.toLowerCase().contains(q) ||
            g.description.toLowerCase().contains(q))
        .toList();
  }

  void _play(QuizGame game) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizPlayScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final games = _filtered;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          Text('MARS PROJEK!', style: comicStyle(fontSize: 34, color: MarsColors.ink)),
          const SizedBox(height: 16),
          Container(
            decoration: comicBox(color: MarsColors.blue),
            padding: const EdgeInsets.all(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: bannerVideoPath.isEmpty
                  ? const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ColoredBox(
                        color: MarsColors.card,
                        child: Center(
                          child: Icon(Icons.play_circle_fill,
                              color: MarsColors.accent, size: 56),
                        ),
                      ),
                    )
                  : VideoBox(path: bannerVideoPath, loop: true, muted: true),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari game...',
              prefixIcon: Icon(Icons.search, color: MarsColors.ink),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 18),
          if (games.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Game tidak ditemukan.',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          for (final g in games) _GameRow(game: g, onPlay: () => _play(g)),
        ],
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  final QuizGame game;
  final VoidCallback onPlay;
  const _GameRow({required this.game, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: comicBox(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MarsColors.yellow,
              border: Border.all(color: MarsColors.ink, width: 3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              game.title.substring(0, 1),
              style: comicStyle(fontSize: 28, color: MarsColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.title,
                    style: comicStyle(fontSize: 22, color: MarsColors.ink)),
                Text(game.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: MarsColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onPlay,
            child: const Text('MAIN!'),
          ),
        ],
      ),
    );
  }
}
