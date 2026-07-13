import 'package:thermo_humi/features/auth/domain/entities/user_entity.dart';
import 'package:thermo_humi/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:thermo_humi/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<UserEntity?> getUserProfile() async {
    return await localDataSource.getUserProfile();
  }
}
