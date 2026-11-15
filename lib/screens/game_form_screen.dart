import 'package:flutter/material.dart';

import '../models/game.dart';

class GameFormScreen extends StatefulWidget {
  final Game? game;
  const GameFormScreen({super.key, this.game});

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _genre;
  late final TextEditingController _developer;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _resellerPrice;

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _title = TextEditingController(text: g?.title ?? '');
    _genre = TextEditingController(text: g?.genre ?? '');
    _developer = TextEditingController(text: g?.developer ?? '');
    _description = TextEditingController(text: g?.description ?? '');
    _price = TextEditingController(text: g?.price.toString() ?? '');
    _resellerPrice = TextEditingController(text: g?.resellerPrice.toString() ?? '');
  }

  @override
  void dispose() {
    for (final c in [_title, _genre, _developer, _description, _price, _resellerPrice]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  String? _number(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return 'Masukkan angka valid';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final game = Game(
      id: widget.game?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      genre: _genre.text.trim(),
      developer: _developer.text.trim(),
      description: _description.text.trim(),
      price: int.parse(_price.text.trim()),
      resellerPrice: int.parse(_resellerPrice.text.trim()),
    );
    Navigator.pop(context, game);
  }

  Widget _field(TextEditingController c, String label,
      {String? Function(String?)? validator,
      int maxLines = 1,
      TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.game != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Game' : 'Tambah Game')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_title, 'Judul', validator: _required),
              _field(_genre, 'Genre', validator: _required),
              _field(_developer, 'Nama developer', validator: _required),
              _field(_description, 'Deskripsi', maxLines: 4, validator: _required),
              _field(_price, 'Harga (Rp)',
                  validator: _number, keyboard: TextInputType.number),
              _field(_resellerPrice, 'Harga reseller (Rp)',
                  validator: _number, keyboard: TextInputType.number),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
