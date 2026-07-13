/// Router Guard — redirect logic dựa vào AuthBloc
library;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/core/router/route_names.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';
import 'package:thermo_humi/core/constants/app_constants.dart';

@singleton
class RouterGuard {
  final SecureStorage _secureStorage;

  RouterGuard(this._secureStorage);

  static bool _isFirstLaunch = true;

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (_isFirstLaunch) {
      _isFirstLaunch = false;
      final rememberMe = await _secureStorage.read('remember_me') == 'true';
      if (!rememberMe) {
        await _secureStorage.delete(AppConstants.kAccessToken);
        await _secureStorage.delete(AppConstants.kRefreshToken);
      }
    }

    final token = await _secureStorage.read(AppConstants.kAccessToken);
    final isAuthenticated = token != null && token.isNotEmpty;

    final isOnSplash = state.matchedLocation == RouteNames.splash;
    final isOnLogin = state.matchedLocation == RouteNames.login;

    // Chưa đăng nhập → về login
    if (!isAuthenticated && !isOnLogin && !isOnSplash) {
      return RouteNames.login;
    }

    // Đã đăng nhập mà vào login → về home
    if (isAuthenticated && isOnLogin) {
      return RouteNames.home;
    }

    return null; // Không redirect
  }
}
