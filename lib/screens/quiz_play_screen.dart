import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../theme.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizGame game;
  const QuizPlayScreen({super.key, required this.game});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final _controller = TextEditingController();
  int _index = 0;
  int _score = 0;
  bool _checked = false;
  bool _correct = false;

  List<QuizQuestion> get _questions => widget.game.questions;
  QuizQuestion get _current => _questions[_index];
  bool get _finished => _index >= _questions.length;

  /// Membandingkan jawaban tanpa spasi, tanda baca, dan perbedaan huruf besar-kecil.
  String _normalize(String s) => s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  void _check() {
    if (_checked) return;
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    setState(() {
      _checked = true;
      _correct = _normalize(input) == _normalize(_current.answer);
      if (_correct) _score++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _checked = false;
      _correct = false;
      _controller.clear();
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _checked = false;
      _correct = false;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.title.toUpperCase())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _finished ? _buildResult() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: comicBox(color: MarsColors.yellow, shadow: 3),
              child: Text('${_index + 1} / ${_questions.length}',
                  style: comicStyle(fontSize: 18, color: MarsColors.ink)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: comicBox(color: MarsColors.blue, shadow: 3),
              child: Text('SKOR $_score',
                  style: comicStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: comicBox(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_current.category != null) ...[
                    Text(_current.category!.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: comicStyle(fontSize: 18, color: MarsColors.accent)),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    _current.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, height: 1.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_checked)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: comicBox(
              color: _correct ? MarsColors.yellow : MarsColors.accent,
              shadow: 3,
            ),
            child: Text(
              _correct ? 'BENAR!' : 'JAWABAN: ${_current.answer.trim()}',
              textAlign: TextAlign.center,
              style: comicStyle(
                fontSize: 22,
                color: _correct ? MarsColors.ink : Colors.white,
              ),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          enabled: !_checked,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontWeight: FontWeight.w700),
          decoration: const InputDecoration(labelText: 'Jawabanmu'),
          onSubmitted: (_) => _checked ? _next() : _check(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _checked ? _next : _check,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_checked ? 'LANJUT!' : 'PERIKSA'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: comicBox(color: MarsColors.yellow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PERMAINAN SELESAI!',
                style: comicStyle(fontSize: 32, color: MarsColors.ink)),
            const SizedBox(height: 10),
            Text('SKOR $_score DARI ${_questions.length}',
                style: comicStyle(fontSize: 22, color: MarsColors.accent)),
            const SizedBox(height: 24),
            FilledButton(onPressed: _restart, child: const Text('MAIN LAGI')),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: MarsColors.ink,
                side: const BorderSide(color: MarsColors.ink, width: 3),
              ),
              child: const Text('KEMBALI'),
            ),
          ],
        ),
      ),
    );
  }
}
