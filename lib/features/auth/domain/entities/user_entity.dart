class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? accessToken;
  final String? refreshToken;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.accessToken,
    required this.refreshToken,
  });
}
