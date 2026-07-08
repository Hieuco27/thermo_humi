import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';

@injectable
class GetAlertsUseCase {
  final AlertRepository _repository;

  GetAlertsUseCase(this._repository);

  Future<PaginatedAlerts> call({String? cursor, int limit = 20}) {
    return _repository.getAlerts(cursor: cursor, limit: limit);
  }
}
