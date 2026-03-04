import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class StartTrackingEvent extends LocationEvent {}

class StopTrackingEvent extends LocationEvent {}

// Event นี้จะถูกเรียกอัตโนมัติเมื่อ GPS มีการขยับ
class OnLocationUpdatedEvent extends LocationEvent {
  final Position position;
  const OnLocationUpdatedEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class OnLocationErrorEvent extends LocationEvent {
  final String message;
  const OnLocationErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}