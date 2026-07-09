import 'package:thermo_humi/features/history/domain/entities/threshold_change_log.dart';

abstract class ThresholdLogRepository {
  Future<(List<ThresholdChangeLog>, bool, String?)> getLogs({
    String? query,
    String? cursor,
    int limit = 20,
  });
}
