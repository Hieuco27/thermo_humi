import 'dart:convert';
import 'package:thermo_humi/core/constants/app_constants.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/features/auth/data/models/user_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserModel?> getUserProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SecureStorage secureStorage;

  ProfileLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<UserModel?> getUserProfile() async {
    final userDataStr = await secureStorage.read(AppConstants.kUserData);
    if (userDataStr != null && userDataStr.isNotEmpty) {
      final userData = jsonDecode(userDataStr);
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
