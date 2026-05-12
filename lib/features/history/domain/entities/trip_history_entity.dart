import 'package:equatable/equatable.dart';

class TripHistoryEntity extends Equatable {
  final int id;
  final String hostName;
  final List<String> memberNames;
  final DateTime startedAt;
  final DateTime endedAt;
  
  // 🟢 สิ่งที่เพิ่มเข้ามาใหม่
  final double totalDistance; // ระยะทางรวม (เมตร)
  final List<double> latitudes; // เก็บเส้นทางละติจูด
  final List<double> longitudes; // เก็บเส้นทางลองจิจูด

  const TripHistoryEntity({
    required this.id,
    required this.hostName,
    required this.memberNames,
    required this.startedAt,
    required this.endedAt,
    required this.totalDistance,
    required this.latitudes,
    required this.longitudes,
  });

  @override
  List<Object?> get props => [
    id, hostName, memberNames, startedAt, endedAt, totalDistance, latitudes, longitudes
  ];
}