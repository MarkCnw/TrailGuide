import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_history_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<TripHistoryEntity> trips;

  const HistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class HistoryEmpty extends HistoryState {}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
