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

    // 2. ดึงพิกัดเริ่มต้นให้เร็วที่สุด (แก้ปัญหารอ GPS นานตอนเริ่ม)
    bool gotInitialPosition = false;

    // ขั้นที่ 1: ลองดึงพิกัดล่าสุดที่เครื่องจำไว้ (ได้ทันที ไม่ต้องรอ)
    try {
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        print("📍 [BLoC] ✅ ใช้พิกัดที่เครื่องจำไว้: Lat ${lastKnown.latitude}, Lng ${lastKnown.longitude}");
        add(OnLocationUpdatedEvent(lastKnown));
        gotInitialPosition = true;
      }
    } catch (e) {
      print("📍 [BLoC] ⚠️ ดึงพิกัดที่จำไว้ไม่ได้: $e");
    }

    // ขั้นที่ 2: ถ้าไม่มีพิกัดที่จำไว้ → ยิง GPS จริงเลย (รอได้แค่ 5 วินาที ถ้าไม่ได้ก็ข้ามไป)
    if (!gotInitialPosition) {
      try {
        Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        print("📍 [BLoC] ✅ ได้พิกัด GPS สด: Lat ${currentPosition.latitude}, Lng ${currentPosition.longitude}");
        add(OnLocationUpdatedEvent(currentPosition));
      } catch (e) {
        print("📍 [BLoC] ⚠️ หา GPS ไม่ทันใน 5 วิ (จะรอจาก Stream แทน): $e");
      }
    }

    // ขั้นที่ 3: เปิด Stream ดูดพิกัดต่อเนื่องเป็นปกติ
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
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