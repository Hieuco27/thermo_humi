import 'package:get_it/get_it.dart';
import 'package:thermo_humi/core/router/router_guard.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/register/register_bloc.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:thermo_humi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:thermo_humi/features/history/data/datasources/threshold_log_mock_data_source.dart';
import 'package:thermo_humi/features/history/data/repositories/threshold_log_repository_impl.dart';
import 'package:thermo_humi/features/history/domain/repositories/threshold_log_repository.dart';

import 'package:thermo_humi/features/notification/data/datasources/mock_alert_data_source.dart';
import 'package:thermo_humi/features/notification/data/repositories/alert_repository_impl.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';
import 'package:thermo_humi/features/notification/domain/usecases/get_alerts_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/resolve_alert_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/watch_alert_events_usecase.dart';
import 'package:thermo_humi/features/notification/presentation/cubit/alert_cubit.dart';

import 'package:thermo_humi/features/history/presentation/bloc/threshold_log_cubit.dart';
import 'package:thermo_humi/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:thermo_humi/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:thermo_humi/features/profile/domain/repositories/profile_repository.dart';
import 'package:thermo_humi/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:thermo_humi/features/profile/presentation/cubit/profile_cubit.dart';

import 'package:thermo_humi/features/member_management/data/repositories/fake_member_repository.dart';
import 'package:thermo_humi/features/member_management/domain/repositories/member_repository.dart';
import 'package:thermo_humi/features/member_management/presentation/cubit/member_cubit.dart';

import 'package:thermo_humi/features/request_access/data/datasources/access_request_remote_data_source.dart';
import 'package:thermo_humi/features/request_access/data/repositories/access_request_repository_impl.dart';
import 'package:thermo_humi/features/request_access/domain/repositories/access_request_repository.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_detail_cubit.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/device_access_request_list_cubit.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/room_access_request_list_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thermo_humi/core/network/dio_client.dart';
import 'package:thermo_humi/core/network/interceptors/auth_interceptor.dart';
import 'package:thermo_humi/core/network/interceptors/error_interceptor.dart';
import 'package:thermo_humi/core/storage/secure_storage.dart';

import 'package:thermo_humi/features/device/presentation/bloc/device_management/device_management_cubit.dart';
import 'package:thermo_humi/features/device/presentation/bloc/device_detail/device_history_cubit.dart';
import 'package:thermo_humi/features/device/domain/repositories/device_repository.dart';
import 'package:thermo_humi/features/device/data/repositories/device_repository_impl.dart';

final sl = GetIt.instance;

void init() {
  // --- Core ---
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage(sl()));
  sl.registerLazySingleton(() => RouterGuard(sl()));

  sl.registerLazySingleton(() => AuthInterceptor(sl()));
  sl.registerLazySingleton(() => ErrorInterceptor());

  sl.registerLazySingleton<Dio>(() => DioClient.createDio(sl(), sl()));

  // --- Auth Feature ---

  // 1. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );

  // 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl<AuthRemoteDataSource>()),
  );

  // 3. UseCases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));

  // 4. Blocs
  sl.registerFactory(() => LoginBloc(signInUseCase: sl()));
  sl.registerFactory(() => RegisterBloc(signUpUseCase: sl()));

  // --- Notification Feature ---
  sl.registerLazySingleton(() => MockAlertDataSource());
  sl.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetAlertsUseCase(sl()));
  sl.registerLazySingleton(() => ResolveAlertUseCase(sl()));
  sl.registerLazySingleton(() => WatchAlertEventsUseCase(sl()));
  sl.registerLazySingleton(() => AlertCubit(sl(), sl(), sl()));

  // --- Capture Feature ---

  // --- Try_On Feature ---

  // --- History Feature ---
  sl.registerLazySingleton<ThresholdLogDataSource>(
    () => MockThresholdLogDataSource(),
  );
  sl.registerLazySingleton<ThresholdLogRepository>(
    () => ThresholdLogRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => ThresholdLogCubit(repository: sl()));

  // --- Profile Feature ---
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerFactory(() => ProfileCubit(sl()));

  // --- Member Management Feature ---
  sl.registerLazySingleton<MemberRepository>(() => FakeMemberRepository());
  sl.registerFactory(() => MemberCubit(repository: sl()));

  // --- Device Management Feature ---
  sl.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl());

  sl.registerFactory(() => DeviceManagementCubit(repository: sl()));
  sl.registerFactory(() => DeviceHistoryCubit(repository: sl()));

  // --- Request Access Feature ---
  sl.registerLazySingleton<AccessRequestRemoteDataSource>(
    () => MockAccessRequestRemoteDataSource(),
  );
  sl.registerLazySingleton<AccessRequestRepository>(
    () => AccessRequestRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => RoomAccessRequestListCubit(repository: sl()));
  sl.registerFactory(() => DeviceAccessRequestListCubit(repository: sl()));
  sl.registerFactory(() => AccessRequestDetailCubit(repository: sl()));
}
