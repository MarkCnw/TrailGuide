import 'package:isar/isar.dart';
part 'trip_history_model.g.dart';

@collection
class TripHistoryModel {
  Id id = Isar.autoIncrement;

  late String hostName;
  late List<String> memberNames;
  late DateTime startedAt;
  late DateTime endedAt;

  // 🟢 สิ่งที่เพิ่มเข้ามาใหม่สำหรับให้ Isar บันทึก
  late double totalDistance;
  late List<double> latitudes;
  late List<double> longitudes;
}