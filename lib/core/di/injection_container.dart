import 'package:get_it/get_it.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:thermo_humi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_bloc.dart';

import 'package:thermo_humi/features/notification/data/datasources/mock_alert_data_source.dart';
import 'package:thermo_humi/features/notification/data/repositories/alert_repository_impl.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';
import 'package:thermo_humi/features/notification/domain/usecases/get_alerts_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/resolve_alert_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/watch_alert_events_usecase.dart';
import 'package:thermo_humi/features/notification/presentation/cubit/alert_cubit.dart';

final sl = GetIt.instance;

void init() {
  // --- Auth Feature ---

  // 1. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authDataSource: sl<AuthRemoteDataSource>()),
  );

  // 3. UseCases
  sl.registerLazySingleton(() => SignInUseCase(sl()));

  // 4. Blocs
  sl.registerFactory(() => LoginBloc(signInUseCase: sl()));

  // --- Notification Feature ---
  sl.registerLazySingleton(() => MockAlertDataSource());
  sl.registerLazySingleton<AlertRepository>(() => AlertRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetAlertsUseCase(sl()));
  sl.registerLazySingleton(() => ResolveAlertUseCase(sl()));
  sl.registerLazySingleton(() => WatchAlertEventsUseCase(sl()));
  sl.registerLazySingleton(() => AlertCubit(sl(), sl(), sl()));

  // --- Capture Feature ---

  // --- Try_On Feature ---
}
