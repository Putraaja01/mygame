import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../models/user.dart';
import '../theme.dart';
import 'kelola_akun_screen.dart';
import 'login_screen.dart';

class AkunScreen extends StatelessWidget {
  final LibraryRepository repo;
  const AkunScreen({super.key, required this.repo});

  void _logout(BuildContext context) {
    repo.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(repo: repo)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = repo.currentUser!;
    final isDev = user.role == UserRole.developer;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AKUN', style: comicStyle(fontSize: 34, color: MarsColors.ink)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: comicBox(color: MarsColors.yellow),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: comicBox(color: MarsColors.card, shadow: 0),
                    child: const Icon(Icons.person, color: MarsColors.ink, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.username,
                            style: comicStyle(fontSize: 24, color: MarsColors.ink)),
                        Text(user.role.label.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900, color: MarsColors.ink)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isDev)
              _MenuTile(
                icon: Icons.group,
                title: 'KELOLA AKUN',
                subtitle: 'Buat akun member dan reseller',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => KelolaAkunScreen(repo: repo)),
                ),
              ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('KELUAR', style: comicStyle(fontSize: 20)),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: MarsColors.ink,
                side: const BorderSide(color: MarsColors.ink, width: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: comicBox(),
        child: Row(
          children: [
            Icon(icon, color: MarsColors.accent, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: comicStyle(fontSize: 22, color: MarsColors.ink)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: MarsColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: MarsColors.ink, size: 28),
          ],
        ),
      ),
    );
  }
}
