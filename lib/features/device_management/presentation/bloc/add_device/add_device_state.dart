part of 'add_device_cubit.dart';

enum AddDeviceStatus { initial, loading, success, error }

class AddDeviceState extends Equatable {
  final AddDeviceStatus status;
  final String? errorMessage;

  const AddDeviceState({
    this.status = AddDeviceStatus.initial,
    this.errorMessage,
  });

  AddDeviceState copyWith({
    AddDeviceStatus? status,
    String? errorMessage,
  }) {
    return AddDeviceState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
