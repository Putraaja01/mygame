import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../models/quiz.dart';
import '../models/user.dart';
import '../theme.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizGame game;
  final LibraryRepository repo;
  const QuizPlayScreen({super.key, required this.game, required this.repo});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final _controller = TextEditingController();
  int _index = 0;
  int _score = 0;
  int _coinsEarned = 0;
  bool _checked = false;
  bool _correct = false;
  bool _hintVisible = false;
  bool _busy = false;

  AppUser get _user => widget.repo.currentUser!;
  List<QuizQuestion> get _questions => widget.game.questions;
  QuizQuestion get _current => _questions[_index];
  bool get _finished => _index >= _questions.length;

  /// Membandingkan jawaban tanpa spasi, tanda baca, dan perbedaan huruf besar-kecil.
  String _normalize(String s) => s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _check() async {
    if (_checked || _busy) return;
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    _busy = true;
    final correct = _normalize(input) == _normalize(_current.answer);
    if (correct) {
      await widget.repo.addCoins(_user, widget.game.coinPerCorrect);
    }
    if (!mounted) return;
    setState(() {
      _checked = true;
      _correct = correct;
      if (correct) {
        _score++;
        _coinsEarned += widget.game.coinPerCorrect;
      }
    });
    _busy = false;
  }

  void _goNext() {
    setState(() {
      _index++;
      _checked = false;
      _correct = false;
      _hintVisible = false;
      _controller.clear();
    });
  }

  Future<void> _useHint() async {
    if (_hintVisible || _checked) return;
    final ok = await widget.repo.useItem(_user, 'hint');
    if (!mounted) return;
    if (!ok) {
      _snack('Kamu belum punya Petunjuk. Beli di Shop.');
      return;
    }
    setState(() => _hintVisible = true);
  }

  Future<void> _useSkip() async {
    if (_checked) return;
    final ok = await widget.repo.useItem(_user, 'skip');
    if (!mounted) return;
    if (!ok) {
      _snack('Kamu belum punya Lewati Soal. Beli di Shop.');
      return;
    }
    _goNext();
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _coinsEarned = 0;
      _checked = false;
      _correct = false;
      _hintVisible = false;
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _hintText() {
    final answer = _current.answer.trim();
    if (answer.isEmpty) return '';
    return answer[0].toUpperCase();
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
    final hintCount = widget.repo.itemCount(_user, 'hint');
    final skipCount = widget.repo.itemCount(_user, 'skip');

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
              decoration: comicBox(color: MarsColors.card, shadow: 3),
              child: Text('KOIN ${widget.repo.coinsOf(_user)}',
                  style: comicStyle(fontSize: 16, color: MarsColors.ink)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: comicBox(color: MarsColors.blue, shadow: 3),
              child: Text('SKOR $_score',
                  style: comicStyle(fontSize: 16, color: Colors.white)),
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
                  if (_hintVisible) ...[
                    const SizedBox(height: 14),
                    Text('Huruf pertama: ${_hintText()}',
                        textAlign: TextAlign.center,
                        style: comicStyle(fontSize: 18, color: MarsColors.blue)),
                  ],
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
              _correct
                  ? 'BENAR! +${widget.game.coinPerCorrect} KOIN'
                  : 'JAWABAN: ${_current.answer.trim()}',
              textAlign: TextAlign.center,
              style: comicStyle(
                fontSize: 20,
                color: _correct ? MarsColors.ink : Colors.white,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (!_checked)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _hintVisible ? null : _useHint,
                  style: _itemStyle(),
                  child: Text('PETUNJUK ($hintCount)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _useSkip,
                  style: _itemStyle(),
                  child: Text('LEWATI ($skipCount)'),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          enabled: !_checked,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontWeight: FontWeight.w700),
          decoration: const InputDecoration(labelText: 'Jawabanmu'),
          onSubmitted: (_) => _checked ? _goNext() : _check(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _checked ? _goNext : _check,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_checked ? 'LANJUT!' : 'PERIKSA'),
          ),
        ),
      ],
    );
  }

  ButtonStyle _itemStyle() => OutlinedButton.styleFrom(
        foregroundColor: MarsColors.ink,
        side: const BorderSide(color: MarsColors.ink, width: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
      );

  Widget _buildResult() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: comicBox(color: MarsColors.yellow),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PERMAINAN SELESAI!',
                textAlign: TextAlign.center,
                style: comicStyle(fontSize: 30, color: MarsColors.ink)),
            const SizedBox(height: 10),
            Text('SKOR $_score DARI ${_questions.length}',
                style: comicStyle(fontSize: 22, color: MarsColors.accent)),
            const SizedBox(height: 6),
            Text('KOIN DIDAPAT: $_coinsEarned',
                style: comicStyle(fontSize: 18, color: MarsColors.ink)),
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
