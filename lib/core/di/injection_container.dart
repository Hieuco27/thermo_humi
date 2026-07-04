import 'package:get_it/get_it.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thermo_humi/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:thermo_humi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thermo_humi/features/auth/domain/repositories/auth_repository.dart';
import 'package:thermo_humi/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:thermo_humi/features/auth/presentation/bloc/login/login_bloc.dart';

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

  // --- Capture Feature ---

  // --- Try_On Feature ---
}
