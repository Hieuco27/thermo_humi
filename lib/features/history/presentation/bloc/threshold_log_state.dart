import 'package:equatable/equatable.dart';

abstract class ThresholdLogState extends Equatable {
  const ThresholdLogState();

  @override
  List<Object?> get props => [];
}

class ThresholdLogInitial extends ThresholdLogState {}

class ThresholdLogLoading extends ThresholdLogState {}

class ThresholdLogLoaded extends ThresholdLogState {
  final List<dynamic> items; // Chứa ThresholdChangeLog và String (date header)
  final bool hasMore;
  final String? nextCursor;

  const ThresholdLogLoaded({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  @override
  List<Object?> get props => [items, hasMore, nextCursor];
}

class ThresholdLogLoadingMore extends ThresholdLogLoaded {
  const ThresholdLogLoadingMore({
    required super.items,
    required super.hasMore,
    super.nextCursor,
  });
}

class ThresholdLogError extends ThresholdLogState {
  final String message;

  const ThresholdLogError(this.message);

  @override
  List<Object?> get props => [message];
}

class ThresholdLogLoadMoreError extends ThresholdLogLoaded {
  final String errorMessage;

  const ThresholdLogLoadMoreError({
    required super.items,
    required super.hasMore,
    super.nextCursor,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [items, hasMore, nextCursor, errorMessage];
}
