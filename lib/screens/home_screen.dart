import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../models/game.dart';
import '../models/user.dart';
import 'game_form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final LibraryRepository repo;
  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  AppUser get _user => widget.repo.currentUser!;

  List<Game> get _filtered {
    final q = _query.toLowerCase();
    return widget.repo.games
        .where((g) =>
            g.title.toLowerCase().contains(q) ||
            g.genre.toLowerCase().contains(q))
        .toList();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _logout() {
    widget.repo.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(repo: widget.repo)),
      (_) => false,
    );
  }

  Future<void> _addOrEdit([Game? game]) async {
    final result = await Navigator.push<Game>(
      context,
      MaterialPageRoute(builder: (_) => GameFormScreen(game: game)),
    );
    if (result == null) return;

    try {
      if (game == null) {
        await widget.repo.addGame(result);
      } else {
        await widget.repo.updateGame(result);
      }
      setState(() {});
    } on AuthException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _delete(Game game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus game?'),
        content: Text('"${game.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await widget.repo.deleteGame(game.id);
      setState(() {});
    } on AuthException catch (e) {
      _snack(e.message);
    }
  }

  void _showDetail(Game g) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(g.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Genre: ${g.genre}'),
              Text('Developer: ${g.developer}'),
              const SizedBox(height: 12),
              Text(g.description),
              const SizedBox(height: 12),
              Text(_priceText(g), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Harga yang terlihat tergantung role.
  String _priceText(Game g) => switch (_user.role) {
        UserRole.member => 'Harga: Rp ${g.price}',
        UserRole.reseller => 'Harga reseller: Rp ${g.resellerPrice}',
        UserRole.developer =>
          'Harga: Rp ${g.price} | Harga reseller: Rp ${g.resellerPrice}',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDev = widget.repo.isDeveloper;
    final games = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Library'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: isDev
          ? FloatingActionButton.extended(
              onPressed: () => _addOrEdit(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Game'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Halo, ${_user.username}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(_user.role.label)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari judul atau genre...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: games.isEmpty
                ? Center(
                    child: Text(
                      widget.repo.games.isEmpty
                          ? (isDev
                              ? 'Belum ada game. Tekan "Tambah Game".'
                              : 'Belum ada game di library.')
                          : 'Game tidak ditemukan.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: games.length,
                    itemBuilder: (_, i) {
                      final g = games[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.videogame_asset)),
                          title: Text(g.title),
                          subtitle: Text('${g.genre} • ${g.developer}'),
                          onTap: () => _showDetail(g),
                          trailing: isDev
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _addOrEdit(g),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _delete(g),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
