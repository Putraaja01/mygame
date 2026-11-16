import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz.dart';
import '../models/shop_item.dart';
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

  /// Limit download harian untuk member. Direset pukul 00.00 zona waktu HP.
  static const dailyMemberLimit = 10;

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
      _createUser(
        username: username,
        password: password,
        role: UserRole.developer,
        enforceSingle: true,
      );

  /// Hanya developer yang boleh membuat akun member, VIP, atau reseller.
  /// Developer tidak dibatasi jumlah akun yang dibuatnya.
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
    await _createUser(
      username: username,
      password: password,
      role: role,
      enforceSingle: false,
    );
  }

  Future<void> _createUser({
    required String username,
    required String password,
    required UserRole role,
    required bool enforceSingle,
  }) async {
    final name = username.trim();

    if (name.length < 3) throw AuthException('Username minimal 3 karakter.');
    if (password.length < 6) throw AuthException('Password minimal 6 karakter.');
    if (_users.any((u) => u.username.toLowerCase() == name.toLowerCase())) {
      throw AuthException('Username sudah digunakan.');
    }
    if (enforceSingle && !isRoleAvailable(role)) {
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

  // ---- Limit download ----

  /// Tanggal hari ini menurut zona waktu HP (reset otomatis pukul 00.00).
  String _todayKey() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  String _quotaKey(String username) => 'quota_${username.toLowerCase()}';

  int _usedToday(AppUser user) {
    final raw = _prefs?.getString(_quotaKey(user.username));
    if (raw == null) return 0;
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0] != _todayKey()) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  /// Sisa download hari ini. Mengembalikan -1 jika tanpa batas (selain member).
  int remainingDownloads(AppUser user) {
    if (user.role != UserRole.member) return -1;
    return (dailyMemberLimit - _usedToday(user)).clamp(0, dailyMemberLimit);
  }

  /// Mengurangi kuota satu kali. Mengembalikan false jika limit member sudah habis.
  Future<bool> consumeDownload(AppUser user) async {
    if (user.role != UserRole.member) return true;
    final used = _usedToday(user);
    if (used >= dailyMemberLimit) return false;
    await _prefs!.setString(
      _quotaKey(user.username),
      '${_todayKey()}|${used + 1}',
    );
    return true;
  }

  // ---- Koin & item shop ----

  String _coinKey(AppUser u) => 'coins_${u.username.toLowerCase()}';
  String _invKey(AppUser u, String itemId) =>
      'inv_${u.username.toLowerCase()}_$itemId';

  int coinsOf(AppUser user) => _prefs?.getInt(_coinKey(user)) ?? 0;

  Future<void> addCoins(AppUser user, int amount) async {
    await _prefs!.setInt(_coinKey(user), coinsOf(user) + amount);
  }

  int itemCount(AppUser user, String itemId) =>
      _prefs?.getInt(_invKey(user, itemId)) ?? 0;

  /// Menukar koin dengan satu item di shop.
  Future<void> buyItem(AppUser user, ShopItem item) async {
    final coins = coinsOf(user);
    if (coins < item.price) throw AuthException('Koin tidak cukup.');
    await _prefs!.setInt(_coinKey(user), coins - item.price);
    await _prefs!.setInt(_invKey(user, item.id), itemCount(user, item.id) + 1);
  }

  /// Memakai satu item. Mengembalikan false jika stok habis.
  Future<bool> useItem(AppUser user, String itemId) async {
    final count = itemCount(user, itemId);
    if (count <= 0) return false;
    await _prefs!.setInt(_invKey(user, itemId), count - 1);
    return true;
  }

  String _newSalt() {
    final rnd = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
