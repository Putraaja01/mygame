import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../theme.dart';

/// Khusus VIP ke atas. Pengunduh belum dihubungkan (lihat catatan).
class TikTokScreen extends StatelessWidget {
  final LibraryRepository repo;
  const TikTokScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final user = repo.currentUser!;
    final allowed = user.role.isVipOrAbove;

    return Scaffold(
      appBar: AppBar(title: const Text('TikTok Downloader')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(allowed ? Icons.download : Icons.lock,
                  size: 56, color: MarsColors.accent),
              const SizedBox(height: 16),
              Text(
                allowed
                    ? 'Fitur TikTok Downloader untuk role VIP ke atas.'
                    : 'Fitur ini khusus role VIP ke atas.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: MarsColors.sand, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
