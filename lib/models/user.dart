enum UserRole { member, reseller, developer }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.member => 'Member',
        UserRole.reseller => 'Reseller',
        UserRole.developer => 'Developer',
      };

  /// Member dan reseller hanya boleh punya satu akun.
  /// Developer boleh punya banyak akun.
  bool get isSingleAccount => this != UserRole.developer;

  static UserRole fromKey(String key) =>
      UserRole.values.firstWhere((r) => r.name == key);
}

class AppUser {
  final String username;
  final String salt;
  final String passwordHash;
  final UserRole role;

  const AppUser({
    required this.username,
    required this.salt,
    required this.passwordHash,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'salt': salt,
        'passwordHash': passwordHash,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'] as String,
        salt: json['salt'] as String,
        passwordHash: json['passwordHash'] as String,
        role: UserRoleX.fromKey(json['role'] as String),
      );
}
