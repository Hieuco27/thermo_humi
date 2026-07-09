import 'package:thermo_humi/features/history/data/datasources/threshold_log_mock_data_source.dart';
import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';
import 'package:thermo_humi/features/history/domain/repositories/threshold_log_repository.dart';

class ThresholdLogRepositoryImpl implements ThresholdLogRepository {
  final ThresholdLogDataSource dataSource;

  ThresholdLogRepositoryImpl({required this.dataSource});

  @override
  Future<(List<ThresholdChangeLog>, bool, String?)> getLogs({
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      return await dataSource.getLogs(
        query: query,
        cursor: cursor,
        limit: limit,
      );
    } catch (e) {
      throw Exception('Failed to fetch logs: $e');
    }
  }
}
