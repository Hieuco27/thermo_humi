import 'package:equatable/equatable.dart';

enum AlertType {
  thresholdExceeded,
  deviceOffline,
  humidityAbnormal,
  deviceOnline,
}

class AlertModel extends Equatable {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isResolved;
  final String deviceId;
  final String? roomId;

  const AlertModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isResolved,
    required this.deviceId,
    this.roomId,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.thresholdExceeded,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool,
      deviceId: json['deviceId'] as String,
      roomId: json['roomId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
      'deviceId': deviceId,
      'roomId': roomId,
    };
  }

  AlertModel copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isResolved,
    String? deviceId,
    String? roomId,
  }) {
    return AlertModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
      deviceId: deviceId ?? this.deviceId,
      roomId: roomId ?? this.roomId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        createdAt,
        isResolved,
        deviceId,
        roomId,
      ];
}
