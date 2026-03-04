import '../repositories/p2p_repository.dart';

class WatchMessages {
  final P2PRepository repository;
  WatchMessages(this.repository);

  Stream<String> call() {
    return repository.messageStream;
  }
}