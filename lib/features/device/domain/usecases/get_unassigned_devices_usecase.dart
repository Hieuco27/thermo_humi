import 'package:dartz/dartz.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';

class GetUnassignedDevicesUseCase {
  final DeviceRepository _repository;

  GetUnassignedDevicesUseCase(this._repository);

  Future<Either<String, List<DeviceEntity>>> execute(String userId) {
    return _repository.getUnassignedDevices(userId);
  }
}
