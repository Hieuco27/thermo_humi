/// AuditLog Entity — lịch sử ghi vết hành động
library;

import 'package:equatable/equatable.dart';

class AuditLogEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final AuditAction action;
  final String resourceType; // 'device' | 'room' | 'threshold' | 'member'
  final String resourceId;
  final String resourceName;
  final Map<String, dynamic>? previousValue;
  final Map<String, dynamic>? newValue;
  final DateTime timestamp;
  final String? note;

  const AuditLogEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.resourceName,
    this.previousValue,
    this.newValue,
    required this.timestamp,
    this.note,
  });

  @override
  List<Object?> get props => [id, userId, action, timestamp];
}

enum AuditAction {
  create,           // Tạo mới
  update,           // Cập nhật
  delete,           // Xóa
  updateThreshold,  // Thay đổi ngưỡng cảnh báo
  shareAccess,      // Chia sẻ quyền
  revokeAccess,     // Thu hồi quyền
  updatePermission, // Thay đổi quyền thành viên
}
