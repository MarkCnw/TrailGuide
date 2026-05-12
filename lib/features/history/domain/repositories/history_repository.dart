import '../entities/trip_history_entity.dart';

abstract class HistoryRepository {
  Future<List<TripHistoryEntity>> getAllTrips();
  Future<void> saveTrip(TripHistoryEntity trip);
}
