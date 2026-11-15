import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../models/user.dart';

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
  UserRole? _role;
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
    if (_role == null) {
      setState(() => _error = 'Pilih role terlebih dahulu.');
      return;
    }

    try {
      await widget.repo.register(
        username: _username.text,
        password: _password.text,
        role: _role!,
      );
      if (mounted) {
        Navigator.of(context).pop('Akun berhasil dibuat. Silakan login.');
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Minimal 3 karakter'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Ulangi password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v != _password.text ? 'Password tidak sama' : null,
                  ),
                  const SizedBox(height: 20),
                  Text('Pilih role', style: theme.textTheme.titleMedium),
                  for (final role in UserRole.values)
                    RadioListTile<UserRole>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(role.label),
                      subtitle: Text(
                        widget.repo.isRoleAvailable(role)
                            ? (role.isSingleAccount
                                ? 'Hanya 1 akun'
                                : 'Akun tidak dibatasi')
                            : 'Sudah ada akun untuk role ini',
                      ),
                      value: role,
                      groupValue: _role,
                      onChanged: widget.repo.isRoleAvailable(role)
                          ? (v) => setState(() {
                                _role = v;
                                _error = null;
                              })
                          : null,
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Daftar'),
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
