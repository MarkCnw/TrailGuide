import '../../domain/entities/trip_history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../models/trip_history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource dataSource;

  HistoryRepositoryImpl(this.dataSource);

  @override
  Future<List<TripHistoryEntity>> getAllTrips() async {
    final models = await dataSource.getAllTrips();
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> saveTrip(TripHistoryEntity trip) async {
    final model = _toModel(trip);
    await dataSource.saveTrip(model);
  }

  // แปลง Model (Isar) → Entity (Domain)
  TripHistoryEntity _toEntity(TripHistoryModel model) {
    return TripHistoryEntity(
      id: model.id,
      hostName: model.hostName,
      memberNames: model.memberNames,
      startedAt: model.startedAt,
      endedAt: model.endedAt,
      totalDistance: model.totalDistance,
      latitudes: model.latitudes,
      longitudes: model.longitudes,
    );
  }

  // แปลง Entity (Domain) → Model (Isar)
  TripHistoryModel _toModel(TripHistoryEntity entity) {
    return TripHistoryModel()
      ..hostName = entity.hostName
      ..memberNames = entity.memberNames
      ..startedAt = entity.startedAt
      ..endedAt = entity.endedAt
      ..totalDistance = entity.totalDistance // 🟢 เซฟข้อมูล
      ..latitudes = entity.latitudes // 🟢 เซฟข้อมูล
      ..longitudes = entity.longitudes; // 🟢 เซฟข้อมูล
  }
}
