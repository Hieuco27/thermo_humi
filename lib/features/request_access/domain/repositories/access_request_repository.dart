import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

abstract class AccessRequestRepository {
  Future<List<AccessRequest>> getDeviceRequests({int page = 1});
  Future<AccessRequest> getDeviceRequestDetail(String id);
  Future<void> respondToDeviceRequest(String id, {required bool accept, AccessRole? roleToGrant});

  Future<List<AccessRequest>> getRoomRequests({int page = 1});
  Future<AccessRequest> getRoomRequestDetail(String id);
  Future<void> respondToRoomRequest(String id, {required bool accept, AccessRole? roleToGrant});
}
