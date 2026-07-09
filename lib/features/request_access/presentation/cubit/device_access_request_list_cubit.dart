import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/request_access/domain/repositories/access_request_repository.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_state.dart';

class DeviceAccessRequestListCubit extends Cubit<AccessRequestListState> {
  final AccessRequestRepository repository;

  DeviceAccessRequestListCubit({required this.repository}) : super(const AccessRequestListState());

  Future<void> fetchRequests() async {
    emit(state.copyWith(status: AccessRequestListStatus.loading));
    try {
      final data = await repository.getDeviceRequests();
      emit(state.copyWith(status: AccessRequestListStatus.loaded, requests: data));
    } catch (e) {
      emit(state.copyWith(status: AccessRequestListStatus.error, errorMessage: e.toString()));
    }
  }
}
