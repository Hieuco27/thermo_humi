import 'package:equatable/equatable.dart';

enum AccessRequestStatus { pending, accepted, declined, expired }

enum AccessRequestType { room, device }

enum AccessRole { guest, member, admin }

extension AccessRoleExtension on AccessRole {
  String get displayName {
    switch (this) {
      case AccessRole.guest:
        return 'Khách';
      case AccessRole.member:
        return 'Thành viên';
      case AccessRole.admin:
        return 'Quản trị';
    }
  }
}

class AccessRequest extends Equatable {
  final String id;
  final String requesterId;
  final String requesterName;
  final String? requesterPhone;
  final String? requesterAvatar;
  final String resourceId;
  final String resourceName;
  final AccessRequestType type;
  final AccessRole roleRequested;
  final AccessRequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? macAddress;

  const AccessRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhone,
    this.requesterAvatar,
    required this.resourceId,
    required this.resourceName,
    required this.type,
    required this.roleRequested,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.macAddress,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AccessRequestStatus get currentStatus {
    if (status == AccessRequestStatus.pending && isExpired) {
      return AccessRequestStatus.expired;
    }
    return status;
  }

  String get requesterInitials {
    if (requesterName.isEmpty) return 'U';
    final parts = requesterName.trim().split(' ');
    if (parts.length > 1) {
      return '${parts.first[0].toUpperCase()}${parts.last[0].toUpperCase()}';
    }
    return requesterName[0].toUpperCase();
  }
  
  String get formattedRequesterName {
    if (requesterName.isEmpty) return '';
    final words = requesterName.trim().split(' ');
    final formatted = words.map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    });
    return formatted.join(' ');
  }

  @override
  List<Object?> get props => [
        id,
        requesterId,
        requesterName,
        requesterPhone,
        requesterAvatar,
        resourceId,
        resourceName,
        type,
        roleRequested,
        status,
        createdAt,
        expiresAt,
        macAddress,
      ];
}
