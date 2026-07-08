import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';

@injectable
class ResolveAlertUseCase {
  final AlertRepository _repository;

  ResolveAlertUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.resolveAlert(id);
  }
}
