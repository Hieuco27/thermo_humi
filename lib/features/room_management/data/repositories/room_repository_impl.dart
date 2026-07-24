import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thermo_humi/features/room/data/datasources/room/room_remote_datasource.dart';
import 'package:thermo_humi/features/room/domain/entities/room_entity.dart';
import 'package:thermo_humi/features/room_management/domain/repositories/room_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: RoomRepository)
class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource _remoteDataSource;

  RoomRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<RoomEntity>>> getRooms(String userId) async {
    try {
      final rooms = await _remoteDataSource.getRooms(userId);
      return Right(rooms);
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = (data is Map && data.containsKey('message')) 
          ? data['message'] 
          : e.message;
      return Left(errorMessage?.toString() ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addRoom(String name) async {
    try {
      await _remoteDataSource.addRoom(name);
      return const Right(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = (data is Map && data.containsKey('message')) 
          ? data['message'] 
          : e.message;
      return Left(errorMessage?.toString() ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
