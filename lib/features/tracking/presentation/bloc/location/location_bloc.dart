import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStream;

  LocationBloc() : super(LocationInitial()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<OnLocationUpdatedEvent>(_onLocationUpdated);
    on<OnLocationErrorEvent>(_onLocationError);
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    // 1. เช็คสิทธิ์ GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      add(const OnLocationErrorEvent('กรุณาเปิด GPS (Location Services)'));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        add(const OnLocationErrorEvent('แอปไม่ได้รับอนุญาตให้ใช้ GPS'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      add(const OnLocationErrorEvent('GPS ถูกบล็อกถาวร กรุณาเปิดใน Setting'));
      return;
    }

    // 2. ถ้าผ่านหมด เริ่มดูดข้อมูลแบบ Stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream?.cancel(); // ยกเลิกอันเก่าก่อนถ้ามี
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        // เมื่อได้พิกัดใหม่ ให้ยิง Event ไปอัปเดต State
        print("📍 [BLoC] GPS Updated: Lat ${position.latitude}, Lng ${position.longitude}");
        add(OnLocationUpdatedEvent(position));
      },
      onError: (error) {
        add(OnLocationErrorEvent('เกิดข้อผิดพลาดกับ GPS: $error'));
      },
    );
  }

  void _onLocationUpdated(
    OnLocationUpdatedEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationTracking(event.position));
  }

  void _onLocationError(
    OnLocationErrorEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationError(event.message));
  }

  void _onStopTracking(
    StopTrackingEvent event,
    Emitter<LocationState> emit,
  ) {
    _positionStream?.cancel();
    _positionStream = null;
    emit(LocationInitial());
  }

  @override
  Future<void> close() {
    _positionStream?.cancel();
    return super.close();
  }
}