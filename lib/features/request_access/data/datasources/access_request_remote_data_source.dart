import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

abstract class AccessRequestRemoteDataSource {
  Future<List<AccessRequest>> getDeviceRequests({int page = 1});
  Future<AccessRequest> getDeviceRequestDetail(String id);
  Future<void> respondToDeviceRequest(
    String id,
    bool accept,
    AccessRole? roleToGrant,
  );

  Future<List<AccessRequest>> getRoomRequests({int page = 1});
  Future<AccessRequest> getRoomRequestDetail(String id);
  Future<void> respondToRoomRequest(
    String id,
    bool accept,
    AccessRole? roleToGrant,
  );
}

class MockAccessRequestRemoteDataSource
    implements AccessRequestRemoteDataSource {
  final List<AccessRequest> _mockData = [
    AccessRequest(
      id: 'req_01',
      requesterId: 'user_t',
      requesterName: 'Bắc',
      resourceId: 'dev_03',
      resourceName: 'Thiết bị 03',
      type: AccessRequestType.device,
      roleRequested: AccessRole.guest,
      status: AccessRequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      expiresAt: DateTime.now().add(const Duration(hours: 23, minutes: 30)),
      macAddress: 'AA:BB:CC:DD:EE:03',
      requesterPhone: '0901234567',
    ),
    AccessRequest(
      id: 'req_02',
      requesterId: 'user_h',
      requesterName: 'Hùng',
      resourceId: 'dev_05',
      resourceName: 'Thiết bị 05',
      type: AccessRequestType.device,
      roleRequested: AccessRole.guest,
      status: AccessRequestStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      expiresAt: DateTime.now().add(const Duration(hours: 21)),
      macAddress: 'AA:BB:CC:DD:EE:05',
      requesterPhone: '0987654321',
    ),
    AccessRequest(
      id: 'req_03',
      requesterId: 'user_tt',
      requesterName: 'Quân',
      resourceId: 'dev_01',
      resourceName: 'Thiết bị 01',
      type: AccessRequestType.device,
      roleRequested: AccessRole.guest,
      status: AccessRequestStatus.declined,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      macAddress: 'AA:BB:CC:DD:EE:01',
    ),
    AccessRequest(
      id: 'req_04',
      requesterId: 'user_expired',
      requesterName: 'Nguyễn Văn Bùi',
      resourceId: 'room_01',
      resourceName: 'Phòng khách',
      type: AccessRequestType.room,
      roleRequested: AccessRole.member,
      status: AccessRequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<AccessRequest>> getDeviceRequests({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockData.where((e) => e.type == AccessRequestType.device).toList();
  }

  @override
  Future<AccessRequest> getDeviceRequestDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.firstWhere(
      (e) => e.id == id && e.type == AccessRequestType.device,
    );
  }

  @override
  Future<void> respondToDeviceRequest(
    String id,
    bool accept,
    AccessRole? roleToGrant,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _mockData.indexWhere(
      (e) => e.id == id && e.type == AccessRequestType.device,
    );
    if (index != -1) {
      _mockData[index] = AccessRequest(
        id: _mockData[index].id,
        requesterId: _mockData[index].requesterId,
        requesterName: _mockData[index].requesterName,
        resourceId: _mockData[index].resourceId,
        resourceName: _mockData[index].resourceName,
        type: _mockData[index].type,
        roleRequested: roleToGrant ?? _mockData[index].roleRequested,
        status: accept
            ? AccessRequestStatus.accepted
            : AccessRequestStatus.declined,
        createdAt: _mockData[index].createdAt,
        expiresAt: _mockData[index].expiresAt,
        macAddress: _mockData[index].macAddress,
        requesterPhone: _mockData[index].requesterPhone,
      );
    } else {
      throw Exception('Không tìm thấy yêu cầu');
    }
  }

  @override
  Future<List<AccessRequest>> getRoomRequests({int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockData.where((e) => e.type == AccessRequestType.room).toList();
  }

  @override
  Future<AccessRequest> getRoomRequestDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockData.firstWhere(
      (e) => e.id == id && e.type == AccessRequestType.room,
    );
  }

  @override
  Future<void> respondToRoomRequest(
    String id,
    bool accept,
    AccessRole? roleToGrant,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _mockData.indexWhere(
      (e) => e.id == id && e.type == AccessRequestType.room,
    );
    if (index != -1) {
      _mockData[index] = AccessRequest(
        id: _mockData[index].id,
        requesterId: _mockData[index].requesterId,
        requesterName: _mockData[index].requesterName,
        resourceId: _mockData[index].resourceId,
        resourceName: _mockData[index].resourceName,
        type: _mockData[index].type,
        roleRequested: roleToGrant ?? _mockData[index].roleRequested,
        status: accept
            ? AccessRequestStatus.accepted
            : AccessRequestStatus.declined,
        createdAt: _mockData[index].createdAt,
        expiresAt: _mockData[index].expiresAt,
        requesterPhone: _mockData[index].requesterPhone,
      );
    } else {
      throw Exception('Không tìm thấy yêu cầu');
    }
  }
}
