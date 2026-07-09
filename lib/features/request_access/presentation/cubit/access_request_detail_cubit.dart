import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';
import 'package:thermo_humi/features/request_access/domain/repositories/access_request_repository.dart';
import 'package:thermo_humi/features/request_access/presentation/cubit/access_request_state.dart';

class AccessRequestDetailCubit extends Cubit<AccessRequestDetailState> {
  final AccessRequestRepository repository;

  AccessRequestDetailCubit({required this.repository}) : super(const AccessRequestDetailState());

  Future<void> fetchDetail(String id, AccessRequestType type) async {
    emit(state.copyWith(status: AccessRequestDetailStatus.loading, clearError: true));
    try {
      final data = type == AccessRequestType.device
          ? await repository.getDeviceRequestDetail(id)
          : await repository.getRoomRequestDetail(id);
      emit(state.copyWith(status: AccessRequestDetailStatus.loaded, request: data, clearError: true));
    } catch (e) {
      emit(state.copyWith(status: AccessRequestDetailStatus.notFound, errorMessage: e.toString()));
    }
  }

  Future<void> respondToRequest(String id, AccessRequestType type, {required bool accept, AccessRole? roleToGrant}) async {
    if (state.request == null) return;
    
    emit(state.copyWith(
      status: AccessRequestDetailStatus.submitting,
      isAccepting: accept,
      isDeclining: !accept,
      clearError: true,
    ));

    try {
      if (type == AccessRequestType.device) {
        await repository.respondToDeviceRequest(id, accept: accept, roleToGrant: roleToGrant);
      } else {
        await repository.respondToRoomRequest(id, accept: accept, roleToGrant: roleToGrant);
      }
      
      await fetchDetail(id, type);
    } catch (e) {
      emit(state.copyWith(
        status: AccessRequestDetailStatus.submitError,
        isAccepting: false,
        isDeclining: false,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: AccessRequestDetailStatus.loaded, clearError: true));
    }
  }
}
