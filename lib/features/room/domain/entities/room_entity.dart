/// Room Entity — phòng / khu vực
library;

import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int totalDevices;
  final int onlineDevices;
  final int alertCount;
  final DateTime createdAt;

  const RoomEntity({
    required this.id,
    required this.name,
    this.description,
    required this.totalDevices,
    required this.onlineDevices,
    required this.alertCount,
    required this.createdAt,
  });

  int get offlineDevices => totalDevices - onlineDevices;
  bool get hasAlert => alertCount > 0;

  @override
  List<Object?> get props => [id, name];
}
