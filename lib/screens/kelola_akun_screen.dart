import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../models/user.dart';
import '../theme.dart';

/// Hanya developer. Membuat akun member, VIP, atau reseller tanpa batas jumlah.
class KelolaAkunScreen extends StatefulWidget {
  final LibraryRepository repo;
  const KelolaAkunScreen({super.key, required this.repo});

  @override
  State<KelolaAkunScreen> createState() => _KelolaAkunScreenState();
}

class _KelolaAkunScreenState extends State<KelolaAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  static const _roles = [UserRole.member, UserRole.vip, UserRole.reseller];
  UserRole? _role;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) {
      _snack('Pilih role terlebih dahulu.');
      return;
    }
    try {
      await widget.repo.createAccount(
        username: _username.text,
        password: _password.text,
        role: _role!,
      );
      _snack('Akun ${_role!.label} berhasil dibuat.');
      _username.clear();
      _password.clear();
      setState(() => _role = null);
      _formKey.currentState!.reset();
    } on AuthException catch (e) {
      _snack(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Buat akun baru',
                  style: TextStyle(fontSize: 20, color: MarsColors.sand)),
              const SizedBox(height: 6),
              const Text('Pilih role untuk akun yang akan dibuat.',
                  style: TextStyle(fontSize: 13, color: MarsColors.muted)),
              const SizedBox(height: 20),
              for (final role in _roles)
                _RoleOption(
                  label: role.label,
                  available: true,
                  selected: _role == role,
                  onTap: () => setState(() => _role = role),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _username,
                style: const TextStyle(color: MarsColors.sand),
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    (v == null || v.trim().length < 3) ? 'Minimal 3 karakter' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true,
                style: const TextStyle(color: MarsColors.sand),
                decoration: const InputDecoration(labelText: 'Password sementara'),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _submit,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('BUAT AKUN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;
  const _RoleOption({
    required this.label,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: MarsColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? MarsColors.accent : MarsColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                      fontSize: 15,
                      color: available ? MarsColors.sand : MarsColors.muted,
                    )),
              ),
              if (!available)
                const Text('Sudah ada akun',
                    style: TextStyle(fontSize: 11, color: MarsColors.muted))
              else if (selected)
                const Icon(Icons.check_circle, color: MarsColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
