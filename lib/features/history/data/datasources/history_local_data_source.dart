import 'package:isar/isar.dart';
import '../models/trip_history_model.dart';

abstract class HistoryLocalDataSource {
  Future<void> saveTrip(TripHistoryModel trip);
  Future<List<TripHistoryModel>> getAllTrips();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  final Isar _isar;

  HistoryLocalDataSourceImpl(this._isar);

  @override
  Future<void> saveTrip(TripHistoryModel trip) async {
    await _isar.writeTxn(() async {
      await _isar.tripHistoryModels.put(trip);
    });
  }

  @override
  Future<List<TripHistoryModel>> getAllTrips() async {
    // เรียงจากใหม่ไปเก่า
    return await _isar.tripHistoryModels
        .where()
        .sortByEndedAtDesc()
        .findAll();
  }
}
