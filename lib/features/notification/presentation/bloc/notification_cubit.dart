import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// ── State ─────────────────────────────────────────────────────────────────────
sealed class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final int unreadCount;
  NotificationLoaded(this.unreadCount);

  @override
  List<Object?> get props => [unreadCount];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
@singleton
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  /// Gọi từ App() — lắng nghe push notification stream
  Future<void> init() async {
    // TODO: Listen to FCM / push notification stream
    emit(NotificationLoaded(0));
  }

  void increment() {
    final current = state;
    if (current is NotificationLoaded) {
      emit(NotificationLoaded(current.unreadCount + 1));
    }
  }

  void clearAll() {
    emit(NotificationLoaded(0));
  }
}
