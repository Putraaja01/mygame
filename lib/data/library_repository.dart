import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Menyimpan user dan game secara lokal (shared_preferences).
/// Password tidak pernah disimpan dalam bentuk teks, hanya hash SHA-256 + salt.
class LibraryRepository {
  static const _usersKey = 'users';
  static const _gamesKey = 'games';

  List<AppUser> _users = [];
  List<Game> _games = [];
  AppUser? _current;
  SharedPreferences? _prefs;

  AppUser? get currentUser => _current;
  List<Game> get games => List.unmodifiable(_games);
  bool get isDeveloper => _current?.role == UserRole.developer;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final rawUsers = _prefs!.getString(_usersKey);
    final rawGames = _prefs!.getString(_gamesKey);

    if (rawUsers != null) {
      _users = (jsonDecode(rawUsers) as List)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (rawGames != null) {
      _games = (jsonDecode(rawGames) as List)
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    await _prefs!.setString(
      _usersKey,
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );
    await _prefs!.setString(
      _gamesKey,
      jsonEncode(_games.map((g) => g.toJson()).toList()),
    );
  }

  // ---------- Akun & role ----------

  bool isRoleAvailable(UserRole role) =>
      !role.isSingleAccount || !_users.any((u) => u.role == role);

  Future<void> register({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    final name = username.trim();

    if (name.length < 3) {
      throw AuthException('Username minimal 3 karakter.');
    }
    if (password.length < 6) {
      throw AuthException('Password minimal 6 karakter.');
    }
    if (_users.any((u) => u.username.toLowerCase() == name.toLowerCase())) {
      throw AuthException('Username sudah digunakan.');
    }
    if (!isRoleAvailable(role)) {
      throw AuthException('Role ${role.label} sudah memiliki akun.');
    }

    final salt = _newSalt();
    _users.add(AppUser(
      username: name,
      salt: salt,
      passwordHash: _hash(salt, password),
      role: role,
    ));
    await _save();
  }

  /// Login hanya berhasil jika username dan password sesuai akun yang terdaftar.
  AppUser login({required String username, required String password}) {
    final name = username.trim().toLowerCase();

    AppUser? user;
    for (final u in _users) {
      if (u.username.toLowerCase() == name) {
        user = u;
        break;
      }
    }

    if (user == null || user.passwordHash != _hash(user.salt, password)) {
      throw AuthException('Username atau password salah.');
    }

    _current = user;
    return user;
  }

  void logout() => _current = null;

  // ---------- Game (khusus developer) ----------

  Future<void> addGame(Game game) async {
    _requireDeveloper();
    _games.add(game);
    await _save();
  }

  Future<void> updateGame(Game game) async {
    _requireDeveloper();
    final i = _games.indexWhere((g) => g.id == game.id);
    if (i < 0) throw AuthException('Game tidak ditemukan.');
    _games[i] = game;
    await _save();
  }

  Future<void> deleteGame(String id) async {
    _requireDeveloper();
    _games.removeWhere((g) => g.id == id);
    await _save();
  }

  void _requireDeveloper() {
    if (!isDeveloper) {
      throw AuthException('Hanya developer yang dapat mengubah game.');
    }
  }

  // ---------- Helper keamanan ----------

  String _newSalt() {
    final rnd = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
