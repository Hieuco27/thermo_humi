import 'package:equatable/equatable.dart';

enum ShareScope { single, room }
enum ShareMethod { emailPhone, qrCode }
enum ShareStatus { initial, loading, success, failure }

class ShareState extends Equatable {
  final ShareScope scope;
  final ShareMethod method;
  final bool allowEdit;
  final List<String> selectedDeviceIds; // Used when Scope == single
  final String? roomId; // Used when Scope == room
  final String inviteInput;
  final String? qrCodeData;
  final int qrRemainingSeconds;
  final ShareStatus status;
  final String? errorMessage;

  const ShareState({
    this.scope = ShareScope.single,
    this.method = ShareMethod.emailPhone,
    this.allowEdit = false,
    this.selectedDeviceIds = const [],
    this.roomId,
    this.inviteInput = '',
    this.qrCodeData,
    this.qrRemainingSeconds = 600, // 10 mins
    this.status = ShareStatus.initial,
    this.errorMessage,
  });

  ShareState copyWith({
    ShareScope? scope,
    ShareMethod? method,
    bool? allowEdit,
    List<String>? selectedDeviceIds,
    String? roomId,
    String? inviteInput,
    String? qrCodeData,
    int? qrRemainingSeconds,
    ShareStatus? status,
    String? errorMessage,
  }) {
    return ShareState(
      scope: scope ?? this.scope,
      method: method ?? this.method,
      allowEdit: allowEdit ?? this.allowEdit,
      selectedDeviceIds: selectedDeviceIds ?? this.selectedDeviceIds,
      roomId: roomId ?? this.roomId,
      inviteInput: inviteInput ?? this.inviteInput,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      qrRemainingSeconds: qrRemainingSeconds ?? this.qrRemainingSeconds,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        scope,
        method,
        allowEdit,
        selectedDeviceIds,
        roomId,
        inviteInput,
        qrCodeData,
        qrRemainingSeconds,
        status,
        errorMessage,
      ];
}
