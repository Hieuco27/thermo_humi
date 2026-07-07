import 'package:flutter_bloc/flutter_bloc.dart';
import 'threshold_settings_event.dart';
import 'threshold_settings_state.dart';

class ThresholdSettingsBloc extends Bloc<ThresholdSettingsEvent, ThresholdSettingsState> {
  ThresholdSettingsBloc() : super(const ThresholdSettingsState()) {
    on<TempRangeChanged>(_onTempRangeChanged);
    on<HumRangeChanged>(_onHumRangeChanged);
    on<SmsAlertToggled>(_onSmsAlertToggled);
    on<PushAlertToggled>(_onPushAlertToggled);
    on<EmailAlertToggled>(_onEmailAlertToggled);
    on<ApplySettingsRequested>(_onApplySettingsRequested);
    on<ApplyToAllRequested>(_onApplyToAllRequested);
  }

  void _onTempRangeChanged(TempRangeChanged event, Emitter<ThresholdSettingsState> emit) {
    emit(state.copyWith(tempMin: event.min, tempMax: event.max));
  }

  void _onHumRangeChanged(HumRangeChanged event, Emitter<ThresholdSettingsState> emit) {
    emit(state.copyWith(humMin: event.min, humMax: event.max));
  }

  void _onSmsAlertToggled(SmsAlertToggled event, Emitter<ThresholdSettingsState> emit) {
    emit(state.copyWith(isSmsEnabled: event.isEnabled));
  }

  void _onPushAlertToggled(PushAlertToggled event, Emitter<ThresholdSettingsState> emit) {
    emit(state.copyWith(isPushEnabled: event.isEnabled));
  }

  void _onEmailAlertToggled(EmailAlertToggled event, Emitter<ThresholdSettingsState> emit) {
    emit(state.copyWith(isEmailEnabled: event.isEnabled));
  }

  Future<void> _onApplySettingsRequested(ApplySettingsRequested event, Emitter<ThresholdSettingsState> emit) async {
    emit(state.copyWith(status: ThresholdSettingsStatus.loading));
    
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1)); 
      
      emit(state.copyWith(status: ThresholdSettingsStatus.success));
      emit(state.copyWith(status: ThresholdSettingsStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        status: ThresholdSettingsStatus.error,
        errorMessage: 'Failed to apply settings',
      ));
    }
  }

  Future<void> _onApplyToAllRequested(ApplyToAllRequested event, Emitter<ThresholdSettingsState> emit) async {
    emit(state.copyWith(status: ThresholdSettingsStatus.loading));
    
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1)); 
      
      emit(state.copyWith(status: ThresholdSettingsStatus.success));
      emit(state.copyWith(status: ThresholdSettingsStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        status: ThresholdSettingsStatus.error,
        errorMessage: 'Failed to apply settings to all devices',
      ));
    }
  }
}
