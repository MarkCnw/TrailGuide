import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip_history_entity.dart';
import '../../domain/usecases/get_all_trips.dart';
import '../../domain/usecases/save_trip.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final GetAllTrips getAllTrips;
  final SaveTrip saveTrip;

  HistoryCubit({
    required this.getAllTrips,
    required this.saveTrip,
  }) : super(HistoryInitial());

  Future<void> loadTrips() async {
    emit(HistoryLoading());
    try {
      final trips = await getAllTrips();
      if (trips.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(trips));
      }
    } catch (e) {
      emit(HistoryError('ไม่สามารถโหลดประวัติได้: $e'));
    }
  }

  Future<void> saveTripRecord(TripHistoryEntity trip) async {
    try {
      await saveTrip(trip);
      // รีโหลดหลังบันทึก
      await loadTrips();
    } catch (e) {
      // ถ้าบันทึกไม่ได้ก็ไม่ crash แค่ print
      print('บันทึกประวัติทริปไม่สำเร็จ: $e');
    }
  }
}
