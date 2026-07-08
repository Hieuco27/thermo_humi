import 'package:injectable/injectable.dart';
import 'package:thermo_humi/features/notification/domain/entities/alert_model.dart';
import 'package:thermo_humi/features/notification/domain/repositories/alert_repository.dart';

@injectable
class WatchAlertEventsUseCase {
  final AlertRepository _repository;

  WatchAlertEventsUseCase(this._repository);

  Stream<AlertModel> call() {
    return _repository.watchAlertEvents();
  }
}
