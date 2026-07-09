import 'package:thermo_humi/features/request_access/data/datasources/access_request_remote_data_source.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/domain/repositories/access_request_repository.dart';

class AccessRequestRepositoryImpl implements AccessRequestRepository {
  final AccessRequestRemoteDataSource remoteDataSource;

  AccessRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AccessRequest>> getDeviceRequests({int page = 1}) {
    return remoteDataSource.getDeviceRequests(page: page);
  }

  @override
  Future<AccessRequest> getDeviceRequestDetail(String id) {
    return remoteDataSource.getDeviceRequestDetail(id);
  }

  @override
  Future<List<AccessRequest>> getRoomRequests({int page = 1}) {
    return remoteDataSource.getRoomRequests(page: page);
  }

  @override
  Future<AccessRequest> getRoomRequestDetail(String id) {
    return remoteDataSource.getRoomRequestDetail(id);
  }

  @override
  Future<void> respondToDeviceRequest(String id, {required bool accept, AccessRole? roleToGrant}) {
    return remoteDataSource.respondToDeviceRequest(id, accept, roleToGrant);
  }

  @override
  Future<void> respondToRoomRequest(String id, {required bool accept, AccessRole? roleToGrant}) {
    return remoteDataSource.respondToRoomRequest(id, accept, roleToGrant);
  }
}
