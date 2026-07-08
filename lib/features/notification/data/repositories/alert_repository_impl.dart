import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/data/datasources/mock_alert_data_source.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';

@LazySingleton(as: AlertRepository)
class AlertRepositoryImpl implements AlertRepository {
  final MockAlertDataSource _dataSource;

  AlertRepositoryImpl(this._dataSource);

  @override
  Future<PaginatedAlerts> getAlerts({String? cursor, int limit = 20}) async {
    final items = await _dataSource.getAlerts(cursor: cursor, limit: limit);
    
    // In a real API, the backend would return hasMore and unresolvedCount
    final hasMore = items.length == limit;
    final nextCursor = items.isNotEmpty ? items.last.id : null;
    
    // Simulate fetching total unresolved count (usually returned by API header/body)
    // For mock, we'll just count from the full mock list for now to simulate the "badge count" logic
    // We can't access full list directly through API conceptually, so we might need a separate API for badge, 
    // but we can mock it here if we assume `getAlerts` returns it.
    // For now, let's just use a hardcoded or accumulated logic.
    // Wait, the data source has the full list. I'll add a helper there or just return a dummy.
    // Let's assume the API returns the exact `unresolvedCount`.
    int mockUnresolvedCount = 0; // We'll handle this in the cubit or mock
    
    return PaginatedAlerts(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
      unresolvedCount: mockUnresolvedCount, // Will be updated by cubit or accurate mock later
    );
  }

  @override
  Future<void> resolveAlert(String id) {
    return _dataSource.resolveAlert(id);
  }

  @override
  Stream<AlertModel> watchAlertEvents() {
    return _dataSource.watchAlertEvents();
  }
}
