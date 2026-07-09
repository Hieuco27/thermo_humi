import 'package:thermo_humi/features/history/data/models/threshold_change_log_model.dart';

abstract class ThresholdLogDataSource {
  Future<(List<ThresholdChangeLogModel>, bool, String?)> getLogs({
    String? query,
    String? cursor,
    int limit = 20,
  });
}

class MockThresholdLogDataSource implements ThresholdLogDataSource {
  final List<ThresholdChangeLogModel> _allLogs = _generateMockLogs();

  @override
  Future<(List<ThresholdChangeLogModel>, bool, String?)> getLogs({
    String? query,
    String? cursor,
    int limit = 20,
  }) async {
    // Giả lập delay mạng 800ms
    await Future.delayed(const Duration(milliseconds: 800));

    // Lọc theo query
    List<ThresholdChangeLogModel> filtered = _allLogs;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered.where((log) {
        return log.userName.toLowerCase().contains(q) ||
            log.deviceName.toLowerCase().contains(q);
      }).toList();
    }

    // Lọc theo cursor cho phân trang
    int startIndex = 0;
    if (cursor != null && cursor.isNotEmpty) {
      final index = filtered.indexWhere((l) => l.id == cursor);
      if (index != -1) {
        startIndex = index + 1; // Bắt đầu từ sau cursor
      }
    }

    if (startIndex >= filtered.length) {
      return (<ThresholdChangeLogModel>[], false, null);
    }

    int endIndex = startIndex + limit;
    bool hasMore = endIndex < filtered.length;
    final paginated = filtered.sublist(
      startIndex,
      hasMore ? endIndex : filtered.length,
    );

    String? nextCursor = paginated.isNotEmpty ? paginated.last.id : null;

    return (paginated, hasMore, nextCursor);
  }

  static List<ThresholdChangeLogModel> _generateMockLogs() {
    final now = DateTime.now();
    return List.generate(100, (index) {
      final isTemp = index % 2 == 0;
      final daysAgo = index ~/ 8; // Tăng dần ngày
      final hoursAgo = index % 8 * 2;
      
      final names = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C'];
      final user = names[index % names.length];
      final initials = user.split(' ').map((e) => e[0]).join();
      
      final devices = ['Kho lạnh 1', 'Kho lạnh 2', 'Phòng Văn phòng'];
      final device = devices[index % devices.length];

      return ThresholdChangeLogModel(
        id: 'log_$index',
        userName: user,
        userInitials: initials,
        timestamp: now.subtract(Duration(days: daysAgo, hours: hoursAgo, minutes: index * 10)),
        deviceName: device,
        metricType: isTemp ? 'Ngưỡng nhiệt độ' : 'Ngưỡng độ ẩm',
        oldValue: isTemp ? '${22.0 + (index % 5).toDouble()}°C–${28.0 + (index % 5).toDouble()}°C' : '${45 + index % 10}%–${75 + index % 10}%',
        newValue: isTemp ? '${20.0 + (index % 5).toDouble()}°C–${30.0 + (index % 5).toDouble()}°C' : '${50 + index % 10}%–${80 + index % 10}%',
      );
    });
  }
}
