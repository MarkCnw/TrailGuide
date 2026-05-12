import '../entities/trip_history_entity.dart';
import '../repositories/history_repository.dart';

class SaveTrip {
  final HistoryRepository repository;

  SaveTrip(this.repository);

  Future<void> call(TripHistoryEntity trip) {
    return repository.saveTrip(trip);
  }
}
