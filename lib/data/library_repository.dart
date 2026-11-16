import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz.dart';
import '../models/user.dart';
import 'quiz_data.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Akun disimpan lokal dengan hash SHA-256 + salt.
/// Daftar game berasal dari lib/data/quiz_data.dart.
class LibraryRepository {
  static const _usersKey = 'users';

  List<AppUser> _users = [];
  AppUser? _current;
  SharedPreferences? _prefs;

  AppUser? get currentUser => _current;
  bool get isDeveloper => _current?.role == UserRole.developer;
  List<QuizGame> get games => quizGames;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_usersKey);
    if (raw != null) {
      _users = (jsonDecode(raw) as List)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _save() async {
    await _prefs!.setString(
      _usersKey,
      jsonEncode(_users.map((u) => u.toJson()).toList()),
    );
  }

  bool isRoleAvailable(UserRole role) =>
      !role.isSingleAccount || !_users.any((u) => u.role == role);

  /// Dipakai untuk membuat akun developer pertama dari halaman daftar.
  Future<void> registerDeveloper({
    required String username,
    required String password,
  }) =>
      _createUser(username: username, password: password, role: UserRole.developer);

  /// Hanya developer yang boleh membuat akun member atau reseller.
  Future<void> createAccount({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    if (!isDeveloper) {
      throw AuthException('Hanya developer yang dapat membuat akun.');
    }
    if (role == UserRole.developer) {
      throw AuthException('Akun developer dibuat dari halaman daftar.');
    }
    await _createUser(username: username, password: password, role: role);
  }

  Future<void> _createUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    final name = username.trim();

    if (name.length < 3) throw AuthException('Username minimal 3 karakter.');
    if (password.length < 6) throw AuthException('Password minimal 6 karakter.');
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

  String _newSalt() {
    final rnd = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
