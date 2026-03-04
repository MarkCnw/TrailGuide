import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trail_guide/features/p2p/domain/entities/peer_entity.dart';
import 'package:trail_guide/features/p2p/domain/repositories/p2p_repository.dart';
import 'package:trail_guide/features/p2p/domain/usecases/broadcast_message.dart';
import 'package:trail_guide/features/p2p/domain/usecases/scan_for_peers.dart';
import 'package:trail_guide/features/p2p/domain/usecases/watch_messages.dart';

import '../../../domain/usecases/watch_peers.dart';

part 'p2p_event.dart';
part 'p2p_state.dart';

class P2PBloc extends Bloc<P2PEvent, P2PState> {
  final ScanForPeers scanForPeers;
  final WatchPeers watchPeers;
  final P2PRepository repository;
  final WatchMessages watchMessages; 
  final BroadcastMessage broadcastMessage; 

  StreamSubscription<List<PeerEntity>>? _peersSubscription;
  StreamSubscription<String>? _messageSubscription; 

  P2PBloc({
    required this.scanForPeers,
    required this.watchPeers,
    required this.repository,
    required this.watchMessages,
    required this.broadcastMessage,
  }) : super(P2PInitial()) {
    // จัดการ Events ทั้งหมด
    on<StartDiscoveryEvent>(_onStartDiscovery);
    on<StartAdvertisingEvent>(_onStartAdvertising);
    on<StopDiscoveryEvent>(_onStopDiscovery);
    on<StopAdvertisingEvent>(_onStopAdvertising);
    on<ConnectToPeerEvent>(_onConnectToPeer);
    on<OnPeersUpdatedEvent>(_onPeersUpdated);
    on<SendStartTripEvent>(_onSendStartTrip);
    on<OnMessageReceivedEvent>(_onMessageReceived);

    // 🔥 เปลี่ยนมาเรียกฟังก์ชันนี้แทน เพื่อดักฟังทั้งเพื่อนและข้อความ
    _subscribeToStreams(); 
  }

  void _subscribeToStreams() {
    // ดักฟังรายชื่อเพื่อน
    _peersSubscription?.cancel();
    _peersSubscription = watchPeers().listen((peers) => add(OnPeersUpdatedEvent(peers)));
    
    // ดักฟังข้อความจากท่อ P2P
    _messageSubscription?.cancel();
    _messageSubscription = watchMessages().listen((message) {
      add(OnMessageReceivedEvent(message));
    });
  }

  // ✅ เมื่อ Host กดปุ่ม Start
  Future<void> _onSendStartTrip(SendStartTripEvent event, Emitter<P2PState> emit) async {
    // 1. ส่งคำสั่งไปบอกทุกคน
    await broadcastMessage("CMD:START_TRIP");
    // 2. ตัว Host เองก็ต้องเปลี่ยนหน้าเหมือนกัน
    emit(P2PTripStarted()); 
  }

  // ✅ เมื่อมีข้อความวิ่งเข้ามาในเครื่อง
  void _onMessageReceived(OnMessageReceivedEvent event, Emitter<P2PState> emit) {
    // ข้อมูลจะมาในรูปแบบ "endpointId|ข้อความ"
    final parts = event.message.split('|');
    if (parts.length == 2) {
      final senderId = parts[0];
      final command = parts[1];

      // ถ้าข้อความคือคำสั่งเริ่มทริป
      if (command == "CMD:START_TRIP") {
        // 🔥 เอา senderId มาใช้ตรงนี้เลย จะได้ไม่ขึ้นเตือน
        print("🚀 Received START command from Host ID: $senderId. Let's go!");
        emit(P2PTripStarted()); 
      }
    }
  }

  // ✅ Logic:  Joiner (สแกนหา Host)
  Future<void> _onStartDiscovery(
    StartDiscoveryEvent event,
    Emitter<P2PState> emit,
  ) async {
    emit(P2PLoading());
    final result = await repository.startDiscovery(event.userName, "star");
    result.fold(
      (failure) => emit(P2PError(failure.message)),
      (_) {}, 
    );
  }

  // ✅ Logic: Host (ประกาศตัวให้คนอื่นเจอ)
  Future<void> _onStartAdvertising(
    StartAdvertisingEvent event,
    Emitter<P2PState> emit,
  ) async {
    emit(P2PLoading());
    final result = await repository.startAdvertising(
      event.hostName,
      "star",
    );
    result.fold((failure) => emit(P2PError(failure.message)), (_) {
      emit(const P2PUpdated([]));
    });
  }

  // ✅ Logic: หยุด Discovery
  Future<void> _onStopDiscovery(
    StopDiscoveryEvent event,
    Emitter<P2PState> emit,
  ) async {
    final result = await repository.stopDiscovery();
    result.fold(
      (failure) => print("Stop Discovery Failed: ${failure.message}"),
      (_) => print("Discovery Stopped"),
    );
  }

  // ✅ Logic: หยุด Advertising
  Future<void> _onStopAdvertising(
    StopAdvertisingEvent event,
    Emitter<P2PState> emit,
  ) async {
    final result = await repository.stopAdvertising();
    result.fold(
      (failure) => print("Stop Advertising Failed: ${failure.message}"),
      (_) => print("Advertising Stopped"),
    );
  }

  // ✅ Logic: เชื่อมต่อกับ Peer
  Future<void> _onConnectToPeer(
    ConnectToPeerEvent event,
    Emitter<P2PState> emit,
  ) async {
    emit(P2PLoading());
    final result = await repository.connectToPeer(event.peerId);
    result.fold(
      (failure) {
        print("Connection Failed: ${failure.message}");
        emit(P2PError(failure.message));
      },
      (_) {
        print("Connection Success/Requested to ${event.peerId}");
        emit(P2PConnected(event.peerId));
      },
    );
  }

  // ✅ Logic:  อัปเดตรายชื่อ Peers
  void _onPeersUpdated(OnPeersUpdatedEvent event, Emitter<P2PState> emit) {
    emit(P2PUpdated(event.peers));
  }

  @override
  Future<void> close() {
    _peersSubscription?.cancel();
    _messageSubscription?.cancel(); 
    repository.stopAll();
    return super.close();
  }
}