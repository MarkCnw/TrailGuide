import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/p2p_repository.dart';

class BroadcastMessage {
  final P2PRepository repository;
  BroadcastMessage(this.repository);

  Future<Either<Failure, void>> call(String message) {
    return repository.broadcastMessage(message);
  }
}