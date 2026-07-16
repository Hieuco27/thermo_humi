/// UseCase — Lấy danh sách phòng kèm thiết bị đang online
/// Gọi RoomRepository và trả về `Either<String, List<RoomWithDevices>>`.
library;

import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/room/domain/repositories/room_repository.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class GetRoomsWithDevicesUseCase {
  final RoomRepository _repository;

  GetRoomsWithDevicesUseCase(this._repository);

  Future<Either<String, List<RoomWithDevices>>> execute() {
    return _repository.getRoomsWithDevices();
  }
}
