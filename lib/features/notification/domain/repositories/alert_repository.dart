import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';

class PaginatedAlerts {
  final List<AlertModel> items;
  final bool hasMore;
  final String? nextCursor;
  final int unresolvedCount;

  const PaginatedAlerts({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    required this.unresolvedCount,
  });
}

abstract class AlertRepository {
  Future<PaginatedAlerts> getAlerts({String? cursor, int limit = 20});
  Future<void> resolveAlert(String id);
  Stream<AlertModel> watchAlertEvents();
}
