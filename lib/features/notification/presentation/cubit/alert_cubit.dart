import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';
import 'package:thermo_humi/features/notification/domain/usecases/get_alerts_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/resolve_alert_usecase.dart';
import 'package:thermo_humi/features/notification/domain/usecases/watch_alert_events_usecase.dart';
import 'package:thermo_humi/features/notification/presentation/cubit/alert_state.dart';

@injectable
class AlertCubit extends Cubit<AlertState> {
  final GetAlertsUseCase _getAlertsUseCase;
  final ResolveAlertUseCase _resolveAlertUseCase;
  final WatchAlertEventsUseCase _watchAlertEventsUseCase;

  StreamSubscription<AlertModel>? _socketSubscription;

  AlertCubit(
    this._getAlertsUseCase,
    this._resolveAlertUseCase,
    this._watchAlertEventsUseCase,
  ) : super(AlertInitial());

  Future<void> init() async {
    emit(AlertLoading());
    try {
      final result = await _getAlertsUseCase();
      // Calculate local unresolved count for mock. In real app, use result.unresolvedCount.
      final unresolvedCount = result.items.where((e) => !e.isResolved).length;

      emit(
        AlertLoaded(
          items: result.items,
          hasMore: result.hasMore,
          nextCursor: result.nextCursor,
          unresolvedCount: unresolvedCount,
        ),
      );

      _listenToSocketEvents();
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is! AlertLoaded) return;
    final currentState = state as AlertLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final result = await _getAlertsUseCase(cursor: currentState.nextCursor);
      final newItems = List<AlertModel>.from(currentState.items)
        ..addAll(result.items);

      emit(
        currentState.copyWith(
          items: newItems,
          hasMore: result.hasMore,
          nextCursor: result.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Revert loading more state
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    // Keep current state to avoid full rebuild UI flash, just fetch new
    try {
      final result = await _getAlertsUseCase();
      final unresolvedCount = result.items.where((e) => !e.isResolved).length;
      emit(
        AlertLoaded(
          items: result.items,
          hasMore: result.hasMore,
          nextCursor: result.nextCursor,
          unresolvedCount: unresolvedCount,
        ),
      );
    } catch (e) {
      // Don't emit error if we already have data, just ignore or show toast (handled in UI)
    }
  }

  Future<void> resolveAlert(String id) async {
    if (state is! AlertLoaded) return;
    final currentState = state as AlertLoaded;

    // Optimistic Update
    final index = currentState.items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final alert = currentState.items[index];
    if (alert.isResolved) return; // Already resolved

    final updatedAlert = alert.copyWith(isResolved: true);
    final newItems = List<AlertModel>.from(currentState.items);
    newItems[index] = updatedAlert;

    final newResolvingIds = Set<String>.from(currentState.resolvingIds)
      ..add(id);

    emit(
      currentState.copyWith(
        items: newItems,
        unresolvedCount: currentState.unresolvedCount > 0
            ? currentState.unresolvedCount - 1
            : 0,
        resolvingIds: newResolvingIds,
      ),
    );

    try {
      await _resolveAlertUseCase(id);

      // Success, remove from resolvingIds
      if (state is AlertLoaded) {
        final successState = state as AlertLoaded;
        final finalResolvingIds = Set<String>.from(successState.resolvingIds)
          ..remove(id);
        emit(successState.copyWith(resolvingIds: finalResolvingIds));
      }
    } catch (e) {
      // Rollback
      if (state is AlertLoaded) {
        final errorState = state as AlertLoaded;
        final rollbackItems = List<AlertModel>.from(errorState.items);
        final rollbackIndex = rollbackItems.indexWhere((e) => e.id == id);
        if (rollbackIndex != -1) {
          rollbackItems[rollbackIndex] = alert; // Revert back to original
        }

        final finalResolvingIds = Set<String>.from(errorState.resolvingIds)
          ..remove(id);

        emit(
          errorState.copyWith(
            items: rollbackItems,
            unresolvedCount: errorState.unresolvedCount + 1,
            resolvingIds: finalResolvingIds,
          ),
        );
      }
    }
  }

  void _listenToSocketEvents() {
    _socketSubscription?.cancel();
    _socketSubscription = _watchAlertEventsUseCase().listen((event) {
      if (state is! AlertLoaded) return;
      final currentState = state as AlertLoaded;

      // Check if it's a new triggered alert or a resolved one
      // Since mock generates new ones, we'll treat it as new if not found, otherwise update
      final index = currentState.items.indexWhere((e) => e.id == event.id);

      if (index == -1) {
        // New alert (Triggered)
        final newItems = List<AlertModel>.from(currentState.items)
          ..insert(0, event);
        final newUnresolved = event.isResolved
            ? currentState.unresolvedCount
            : currentState.unresolvedCount + 1;
        emit(
          currentState.copyWith(
            items: newItems,
            unresolvedCount: newUnresolved,
          ),
        );
      } else {
        // Updated alert (Resolved by BE)
        final oldAlert = currentState.items[index];
        if (!oldAlert.isResolved && event.isResolved) {
          final newItems = List<AlertModel>.from(currentState.items);
          newItems[index] = event;
          final newUnresolved = currentState.unresolvedCount > 0
              ? currentState.unresolvedCount - 1
              : 0;
          emit(
            currentState.copyWith(
              items: newItems,
              unresolvedCount: newUnresolved,
            ),
          );
        }
      }
    });
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }
}
