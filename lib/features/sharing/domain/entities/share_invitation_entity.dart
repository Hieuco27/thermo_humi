/// ShareInvitation Entity — chia sẻ quyền truy cập
library;

import 'package:equatable/equatable.dart';

class ShareInvitationEntity extends Equatable {
  final String id;
  final String resourceId;
  final String resourceType; // 'room' | 'device'
  final String resourceName;
  final String senderId;
  final String? recipientPhone;
  final String? recipientEmail;
  final ShareInvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const ShareInvitationEntity({
    required this.id,
    required this.resourceId,
    required this.resourceType,
    required this.resourceName,
    required this.senderId,
    this.recipientPhone,
    this.recipientEmail,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == ShareInvitationStatus.pending;

  @override
  List<Object?> get props => [id, resourceId, status];
}

enum ShareInvitationStatus {
  pending, // Chờ chấp nhận
  accepted, // Đã chấp nhận
  rejected, // Đã từ chối
  expired, // Hết hạn
  revoked, // Đã thu hồi
}
