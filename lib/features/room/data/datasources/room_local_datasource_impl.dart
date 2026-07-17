import 'package:hive/hive.dart';
import 'package:thermo_humi/features/room/data/datasources/room_local_datasource.dart';
import 'package:thermo_humi/features/room/data/models/hive/room_hive_model.dart';
import 'package:thermo_humi/features/room/presentation/models/room_with_devices.dart';

class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  static const String boxName = 'rooms';

  @override
  Future<void> saveRoomsWithDevices(List<RoomWithDevices> rooms) async {
    final box = Hive.box<RoomHiveModel>(boxName);
    
    // Convert entities to Hive models
    final hiveModels = rooms.map((r) => RoomHiveModel.fromEntity(r)).toList();
    
    // Clear old data and save new data
    await box.clear();
    await box.addAll(hiveModels);
  }

  @override
  Future<List<RoomWithDevices>> getRoomsWithDevices() async {
    final box = Hive.box<RoomHiveModel>(boxName);
    
    // Convert Hive models back to entities
    final rooms = box.values.map((model) => model.toEntity()).toList();
    return rooms;
  }
}
