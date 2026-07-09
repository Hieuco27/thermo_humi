import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';
import 'package:thermo_humi/features/history/domain/repositories/threshold_log_repository.dart';
import 'package:thermo_humi/features/history/presentation/bloc/threshold_log_state.dart';

class ThresholdLogCubit extends Cubit<ThresholdLogState> {
  final ThresholdLogRepository repository;

  // Lõi lưu trữ
  final List<ThresholdChangeLog> _logs = [];
  String? _currentQuery;

  ThresholdLogCubit({required this.repository}) : super(ThresholdLogInitial());

  Future<void> fetchLogs({String? query, bool isRefresh = false}) async {
    try {
      if (isRefresh || query != _currentQuery) {
        emit(ThresholdLogLoading());
        _logs.clear();
        _currentQuery = query;
      }

      final (newLogs, hasMore, nextCursor) = await repository.getLogs(
        query: _currentQuery,
        cursor: null,
      );

      _logs.addAll(newLogs);
      emit(
        ThresholdLogLoaded(
          items: _groupLogsByDate(_logs),
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e) {
      emit(ThresholdLogError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ThresholdLogLoaded ||
        currentState is ThresholdLogLoadingMore)
      return;
    if (!currentState.hasMore) return;

    try {
      emit(
        ThresholdLogLoadingMore(
          items: currentState.items,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
        ),
      );

      final (newLogs, hasMore, nextCursor) = await repository.getLogs(
        query: _currentQuery,
        cursor: currentState.nextCursor,
      );

      _logs.addAll(newLogs);

      emit(
        ThresholdLogLoaded(
          items: _groupLogsByDate(_logs),
          hasMore: hasMore,
          nextCursor: nextCursor,
        ),
      );
    } catch (e) {
      emit(
        ThresholdLogLoadMoreError(
          items: currentState.items,
          hasMore: currentState.hasMore,
          nextCursor: currentState.nextCursor,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void search(String query) {
    fetchLogs(query: query);
  }

  List<dynamic> _groupLogsByDate(List<ThresholdChangeLog> logs) {
    if (logs.isEmpty) return [];

    final List<dynamic> grouped = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateFormat = DateFormat('dd/MM/yyyy');

    String? lastDateHeader;

    for (final log in logs) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );

      String header;
      if (logDate == today) {
        header = 'Hôm nay';
      } else if (logDate == yesterday) {
        header = 'Hôm qua';
      } else {
        header = dateFormat.format(logDate);
      }

      if (header != lastDateHeader) {
        grouped.add(header);
        lastDateHeader = header;
      }

      grouped.add(log);
    }

    return grouped;
  }
}
