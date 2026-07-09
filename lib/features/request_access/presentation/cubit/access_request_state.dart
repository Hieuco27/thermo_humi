import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/request_access/domain/entities/access_request.dart';

// --- LIST STATE ---
enum AccessRequestListStatus { initial, loading, loaded, error }

class AccessRequestListState extends Equatable {
  final AccessRequestListStatus status;
  final List<AccessRequest> requests;
  final String? errorMessage;
  final bool isLoadingMore;

  const AccessRequestListState({
    this.status = AccessRequestListStatus.initial,
    this.requests = const [],
    this.errorMessage,
    this.isLoadingMore = false,
  });

  AccessRequestListState copyWith({
    AccessRequestListStatus? status,
    List<AccessRequest>? requests,
    String? errorMessage,
    bool? isLoadingMore,
    bool clearError = false,
  }) {
    return AccessRequestListState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  Map<DateTime, List<AccessRequest>> get groupedByDate {
    final map = <DateTime, List<AccessRequest>>{};
    for (var request in requests) {
      final date = DateTime(
        request.createdAt.year,
        request.createdAt.month,
        request.createdAt.day,
      );
      map.putIfAbsent(date, () => []).add(request);
    }
    return map;
  }

  @override
  List<Object?> get props => [status, requests, errorMessage, isLoadingMore];
}

// --- DETAIL STATE ---
enum AccessRequestDetailStatus { initial, loading, loaded, submitting, submitError, notFound }

class AccessRequestDetailState extends Equatable {
  final AccessRequestDetailStatus status;
  final AccessRequest? request;
  final String? errorMessage;
  final bool isAccepting;
  final bool isDeclining;

  const AccessRequestDetailState({
    this.status = AccessRequestDetailStatus.initial,
    this.request,
    this.errorMessage,
    this.isAccepting = false,
    this.isDeclining = false,
  });

  AccessRequestDetailState copyWith({
    AccessRequestDetailStatus? status,
    AccessRequest? request,
    String? errorMessage,
    bool? isAccepting,
    bool? isDeclining,
    bool clearError = false,
  }) {
    return AccessRequestDetailState(
      status: status ?? this.status,
      request: request ?? this.request,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAccepting: isAccepting ?? this.isAccepting,
      isDeclining: isDeclining ?? this.isDeclining,
    );
  }

  @override
  List<Object?> get props => [status, request, errorMessage, isAccepting, isDeclining];
}
