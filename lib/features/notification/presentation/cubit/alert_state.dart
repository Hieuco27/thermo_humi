import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';

abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}

class AlertLoading extends AlertState {}

class AlertLoaded extends AlertState {
  final List<AlertModel> items;
  final bool hasMore;
  final String? nextCursor;
  final int unresolvedCount;
  final Set<String> resolvingIds;
  final bool isLoadingMore; // To show spinner at the bottom

  const AlertLoaded({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    required this.unresolvedCount,
    this.resolvingIds = const {},
    this.isLoadingMore = false,
  });

  AlertLoaded copyWith({
    List<AlertModel>? items,
    bool? hasMore,
    String? nextCursor,
    int? unresolvedCount,
    Set<String>? resolvingIds,
    bool? isLoadingMore,
  }) {
    return AlertLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      unresolvedCount: unresolvedCount ?? this.unresolvedCount,
      resolvingIds: resolvingIds ?? this.resolvingIds,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        items,
        hasMore,
        nextCursor,
        unresolvedCount,
        resolvingIds,
        isLoadingMore,
      ];
}

class AlertError extends AlertState {
  final String message;

  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}
