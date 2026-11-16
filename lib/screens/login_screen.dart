import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../services/music.dart';
import '../theme.dart';
import 'intro_video_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final LibraryRepository repo;
  const LoginScreen({super.key, required this.repo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    try {
      widget.repo.login(username: _username.text, password: _password.text);
      Music.play();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => IntroVideoScreen(repo: widget.repo)),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _goToRegister() async {
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen(repo: widget.repo)),
    );
    if (message != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const Icon(Icons.public, size: 64, color: MarsColors.accent),
                  const SizedBox(height: 16),
                  const Text(
                    'MARS PROJEK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 6,
                      color: MarsColors.sand,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'MASUK KE MISI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: MarsColors.muted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _username,
                    style: const TextStyle(color: MarsColors.sand),
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    style: const TextStyle(color: MarsColors.sand),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          color: MarsColors.muted,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                    onFieldSubmitted: (_) => _submit(),
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
                      child: Text('MASUK'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _goToRegister,
                    child: const Text('Daftar akun developer',
                        style: TextStyle(color: MarsColors.muted)),
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
