import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/device/domain/entities/device_entity.dart';
import 'threshold_settings_state.dart';

class ThresholdSettingsCubit extends Cubit<ThresholdSettingsState> {
  ThresholdSettingsCubit(DeviceEntity device)
    : super(
        ThresholdSettingsState(
          tempMin: device.threshold?.tempLow ?? 18.0,
          tempMax: device.threshold?.tempHigh ?? 28.0,
          humMin: device.threshold?.humidLow ?? 50.0,
          humMax: device.threshold?.humidHigh ?? 75.0,
          // Defaults for alerts
          isSmsEnabled: true,
          isPushEnabled: true,
          isEmailEnabled: false,
        ),
      );

  void updateTempRange(double min, double max) {
    emit(state.copyWith(tempMin: min, tempMax: max));
  }

  void updateHumRange(double min, double max) {
    emit(state.copyWith(humMin: min, humMax: max));
  }

  void toggleSmsAlert(bool isEnabled) {
    emit(state.copyWith(isSmsEnabled: isEnabled));
  }

  void togglePushAlert(bool isEnabled) {
    emit(state.copyWith(isPushEnabled: isEnabled));
  }

  void toggleEmailAlert(bool isEnabled) {
    emit(state.copyWith(isEmailEnabled: isEnabled));
  }

  Future<void> applySettings(String deviceId) async {
    emit(state.copyWith(status: ThresholdSettingsStatus.loading));

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(status: ThresholdSettingsStatus.success));
      emit(state.copyWith(status: ThresholdSettingsStatus.initial));
    } catch (e) {
      emit(
        state.copyWith(
          status: ThresholdSettingsStatus.error,
          errorMessage: 'Failed to apply settings',
        ),
      );
    }
  }

  Future<void> applyToAll() async {
    emit(state.copyWith(status: ThresholdSettingsStatus.loading));
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      emit(state.copyWith(status: ThresholdSettingsStatus.success));
      emit(state.copyWith(status: ThresholdSettingsStatus.initial));
    } catch (e) {
      emit(
        state.copyWith(
          status: ThresholdSettingsStatus.error,
          errorMessage: 'Failed to apply settings to all devices',
        ),
      );
    }
  }
}
