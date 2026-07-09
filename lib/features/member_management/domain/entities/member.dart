import 'package:equatable/equatable.dart';

enum MemberRole { admin, editor, viewer }

extension MemberRoleX on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.editor:
        return 'Editor';
      case MemberRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case MemberRole.admin:
        return 'Toàn quyền quản trị, bao gồm phân quyền';
      case MemberRole.editor:
        return 'Xem và chỉnh sửa cấu hình thiết bị';
      case MemberRole.viewer:
        return 'Chỉ xem thông số, không chỉnh sửa';
    }
  }
}

class Member extends Equatable {
  final String id;
  final String name;
  final String email;
  final MemberRole role;
  final bool isPending;
  final bool isCurrentUser;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isPending = false,
    this.isCurrentUser = false,
  });

  String get initials {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return parts[0][0].toUpperCase() + parts.last[0].toUpperCase();
  }

  Member copyWith({
    String? id,
    String? name,
    String? email,
    MemberRole? role,
    bool? isPending,
    bool? isCurrentUser,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isPending: isPending ?? this.isPending,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, isPending, isCurrentUser];
}
