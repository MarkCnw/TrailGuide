import '../entities/trip_history_entity.dart';
import '../repositories/history_repository.dart';

class GetAllTrips {
  final HistoryRepository repository;

  GetAllTrips(this.repository);

  Future<List<TripHistoryEntity>> call() {
    return repository.getAllTrips();
  }
}
