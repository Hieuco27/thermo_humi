import 'package:equatable/equatable.dart';

abstract class ThresholdSettingsEvent extends Equatable {
  const ThresholdSettingsEvent();

  @override
  List<Object?> get props => [];
}

class TempRangeChanged extends ThresholdSettingsEvent {
  final double min;
  final double max;

  const TempRangeChanged(this.min, this.max);

  @override
  List<Object?> get props => [min, max];
}

class HumRangeChanged extends ThresholdSettingsEvent {
  final double min;
  final double max;

  const HumRangeChanged(this.min, this.max);

  @override
  List<Object?> get props => [min, max];
}

class SmsAlertToggled extends ThresholdSettingsEvent {
  final bool isEnabled;

  const SmsAlertToggled(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class PushAlertToggled extends ThresholdSettingsEvent {
  final bool isEnabled;

  const PushAlertToggled(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class EmailAlertToggled extends ThresholdSettingsEvent {
  final bool isEnabled;

  const EmailAlertToggled(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class ApplySettingsRequested extends ThresholdSettingsEvent {
  final String deviceId;

  const ApplySettingsRequested(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class ApplyToAllRequested extends ThresholdSettingsEvent {
  const ApplyToAllRequested();

  @override
  List<Object?> get props => [];
}
