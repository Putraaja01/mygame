import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../theme.dart';

/// Hanya untuk membuat akun developer. Akun member dan reseller dibuat developer.
class RegisterScreen extends StatefulWidget {
  final LibraryRepository repo;
  const RegisterScreen({super.key, required this.repo});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await widget.repo.registerDeveloper(
        username: _username.text,
        password: _password.text,
      );
      if (mounted) {
        Navigator.of(context).pop('Akun developer berhasil dibuat. Silakan masuk.');
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar developer')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _username,
                    style: const TextStyle(color: MarsColors.sand),
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Minimal 3 karakter'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: MarsColors.sand),
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    style: const TextStyle(color: MarsColors.sand),
                    decoration: const InputDecoration(labelText: 'Ulangi password'),
                    validator: (v) =>
                        v != _password.text ? 'Password tidak sama' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: MarsColors.accent)),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('DAFTAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
