import 'package:equatable/equatable.dart';

enum ThresholdSettingsStatus { initial, loading, success, error }

class ThresholdSettingsState extends Equatable {
  final ThresholdSettingsStatus status;
  final double tempMin;
  final double tempMax;
  final double humMin;
  final double humMax;
  final bool isSmsEnabled;
  final bool isPushEnabled;
  final bool isEmailEnabled;
  final String? errorMessage;

  const ThresholdSettingsState({
    this.status = ThresholdSettingsStatus.initial,
    this.tempMin = 18.0,
    this.tempMax = 28.0,
    this.humMin = 50.0,
    this.humMax = 75.0,
    this.isSmsEnabled = true,
    this.isPushEnabled = true,
    this.isEmailEnabled = false,
    this.errorMessage,
  });

  ThresholdSettingsState copyWith({
    ThresholdSettingsStatus? status,
    double? tempMin,
    double? tempMax,
    double? humMin,
    double? humMax,
    bool? isSmsEnabled,
    bool? isPushEnabled,
    bool? isEmailEnabled,
    String? errorMessage,
  }) {
    return ThresholdSettingsState(
      status: status ?? this.status,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humMin: humMin ?? this.humMin,
      humMax: humMax ?? this.humMax,
      isSmsEnabled: isSmsEnabled ?? this.isSmsEnabled,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      isEmailEnabled: isEmailEnabled ?? this.isEmailEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tempMin,
        tempMax,
        humMin,
        humMax,
        isSmsEnabled,
        isPushEnabled,
        isEmailEnabled,
        errorMessage,
      ];
}
