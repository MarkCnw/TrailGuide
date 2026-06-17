import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart'; // 🆕 นำเข้า debugPrint
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trail_guide/features/p2p/datasources/p2p_native_data_source.dart';
import 'package:trail_guide/features/p2p/domain/entities/peer_entity.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/p2p_repository.dart';

/// Implementation ของ P2PRepository (เวอร์ชัน Native 100%)
class P2PRepositoryImpl implements P2PRepository {
  final P2PNativeDataSource nativeDataSource;

  P2PRepositoryImpl({required this.nativeDataSource}) {
    nativeDataSource.messageStream.listen((eventData) {
      // โยนข้อมูลที่ไหลมาให้พนักงานคัดแยกจัดการ
      _handleNativeEvent(eventData); 
    });
  }

  // ============================================================
  // STREAMS & CONTROLLERS
  // ============================================================

  final _peerStreamController = StreamController<List<PeerEntity>>.broadcast();
  final List<PeerEntity> _discoveredPeers = [];
  final List<PeerEntity> _connectedPeers = [];
  final _messageStreamController = StreamController<String>.broadcast();
  final List<String> _connectedEndpoints = [];

  // ============================================================
  // CALLBACKS (ของเก่าจาก Interface - ปล่อยว่างไว้)
  // ============================================================

  @override
  set onPayloadReceived(OnPayloadReceivedCallback? callback) {}

  // ============================================================
  // พนักงานคัดแยกข้อมูลจาก Native (Android)
  // ============================================================
  void _handleNativeEvent(String eventData) {
    // หั่นข้อความด้วยเครื่องหมาย |
    final parts = eventData.split('|'); 
    if (parts.isEmpty) return;

    final command = parts[0]; // ป้ายชื่อคำสั่ง เช่น FOUND, MESSAGE

    switch (command) {
      case 'FOUND': // สแกนเจอเพื่อน
        if (parts.length >= 3) {
          final id = parts[1];
          final name = parts[2];
          // ถ้ายังไม่มีชื่อใน List ให้เพิ่มเข้าไป แล้วอัปเดตหน้าจอ
          if (!_discoveredPeers.any((p) => p.id == id)) {
            _discoveredPeers.add(PeerEntity(id: id, name: name, rssi: 0, isLost: false));
            _updatePeersStream(); 
          }
        }
        break;

      case 'LOST': // เพื่อนเดินออกนอกระยะ
        if (parts.length >= 2) {
          final id = parts[1];
          _discoveredPeers.removeWhere((p) => p.id == id);
          _updatePeersStream();
        }
        break;

      case 'INITIATED': // มีคนขอจับมือเชื่อมต่อ
        if (parts.length >= 3) {
          final id = parts[1];
          final name = parts[2];
          _pendingConnectionNames[id] = name;
          
          // ระบบ Auto-Accept: ถ้ายอมรับอัตโนมัติ ให้กดยอมรับเลย
          if (!_acceptedPeers.contains(id)) {
            _acceptedPeers.add(id);
            acceptConnection(id);
          }
        }
        break;

      case 'CONNECTED': // เชื่อมต่อสำเร็จ! เข้าห้องแล้ว
        if (parts.length >= 2) {
          final id = parts[1];
          final peerName = _pendingConnectionNames[id] ?? 'Unknown';
          
          // ย้ายเข้าลิสต์คนที่เชื่อมต่อแล้ว
          if (!_connectedPeers.any((p) => p.id == id)) {
            _connectedPeers.add(PeerEntity(id: id, name: peerName, rssi: 0, isLost: false));
          }
          if (!_connectedEndpoints.contains(id)) {
            _connectedEndpoints.add(id);
          }
          _pendingConnectionNames.remove(id); // ลบออกจากคิวรอ
          _updatePeersStream(); // อัปเดตหน้าจอ
        }
        break;

      case 'REJECTED': // ถูกปฏิเสธ หรือการเชื่อมต่อล้มเหลว
        if (parts.length >= 2) {
          final id = parts[1];
          _pendingConnectionNames.remove(id);
          _acceptedPeers.remove(id);
        }
        break;

      case 'DISCONNECTED': // ขาดการเชื่อมต่อ หรือเขากดวางสาย
        if (parts.length >= 2) {
          final id = parts[1];
          _connectedPeers.removeWhere((p) => p.id == id);
          _acceptedPeers.remove(id);
          _connectedEndpoints.remove(id);
          _updatePeersStream(); // อัปเดตหน้าจอว่าเพื่อนหายไปแล้ว
        }
        break;

      case 'MESSAGE': // มีข้อความแชทส่งมา
        if (parts.length >= 3) {
          final id = parts[1];
          // รวมข้อความกลับไปเผื่อในแชทมีการพิมพ์เครื่องหมาย | มาด้วย จะได้ไม่พัง
          final message = parts.sublist(2).join('|'); 
          
          // โยนเข้า BLoC ตามฟอร์แมตเดิมที่คุณเคยทำไว้
          _messageStreamController.add("$id|$message"); 
        }
        break;
    }
  }

  @override
  set onPeerDisconnected(OnPeerDisconnectedCallback? callback) {}

  @override
  set onNewConnection(OnConnectionCallback? callback) {}

  // ============================================================
  // STATE
  // ============================================================

  bool _isDiscovering = false;
  bool _isAdvertising = false;
  Timer? _retryTimer;

  final Map<String, String> _pendingConnectionNames = {};
  final Set<String> _acceptedPeers = {};

  // ============================================================
  // GETTERS
  // ============================================================

  @override
  Stream<List<PeerEntity>> get peersStream => _peerStreamController.stream;

  @override
  int get connectedPeersCount => _connectedPeers.length;

  @override
  List<PeerEntity> get connectedPeers => List.unmodifiable(_connectedPeers);

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  bool get isDiscovering => _isDiscovering;

  @override
  Stream<String> get messageStream => _messageStreamController.stream;

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<Either<Failure, bool>> _checkPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(P2PFailure('กรุณาเปิด Location Service (GPS)'));
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ].request();

      if (statuses[Permission.location]?.isDenied ?? true) {
        return const Left(P2PFailure('กรุณาอนุญาต Location Permission'));
      }

      if (statuses[Permission.bluetoothScan]?.isDenied ?? true) {
        return const Left(P2PFailure('กรุณาอนุญาต Bluetooth Scan Permission'));
      }

      return const Right(true);
    } catch (e) {
      return Left(P2PFailure('Permission Error: $e'));
    }
  }

  // ============================================================
  // DISCOVERY (Member Side)
  // ============================================================

  @override
  Future<Either<Failure, void>> startDiscovery(
    String userName,
    String strategy,
  ) async {
    try {
      if (_isDiscovering) {
        await nativeDataSource.stopNativeDiscovery();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final permissionResult = await _checkPermissions();
      if (permissionResult.isLeft()) {
        return permissionResult.fold(
          (failure) => Left(failure),
          (_) => const Left(P2PFailure('Permission Error')),
        );
      }

      _discoveredPeers.clear();
      _updatePeersStream();
      
      await nativeDataSource.startNativeDiscovery(userName);
      _isDiscovering = true;
      _startRetryTimer(userName);
      
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('ไม่สำเร็จ: $e'));
    }
  }

  void _startRetryTimer(String userName) {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isDiscovering) {
        await nativeDataSource.stopNativeDiscovery();
        await Future.delayed(const Duration(milliseconds: 500));
        if (_isDiscovering) {
          await nativeDataSource.startNativeDiscovery(userName);
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> stopDiscovery() async {
    try {
      _isDiscovering = false;
      _retryTimer?.cancel();
      await nativeDataSource.stopNativeDiscovery();
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Stop Discovery Error: $e'));
    }
  }

  // ============================================================
  // ADVERTISING (Host Side)
  // ============================================================

  @override
  Future<Either<Failure, void>> startAdvertising(
    String userName,
    String strategy,
  ) async {
    try {
      if (_isAdvertising) {
        await nativeDataSource.stopNativeAdvertising();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final permissionResult = await _checkPermissions();
      if (permissionResult.isLeft()) {
        return permissionResult.fold(
          (failure) => Left(failure),
          (_) => const Left(P2PFailure('Permission Error')),
        );
      }

      _connectedPeers.clear();
      _acceptedPeers.clear();

      await nativeDataSource.startNativeAdvertising(userName);
      _isAdvertising = true;
      
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Advertising Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stopAdvertising() async {
    try {
      _isAdvertising = false;
      await nativeDataSource.stopNativeAdvertising();
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Stop Advertising Error: $e'));
    }
  }

  // ============================================================
  // CONNECTION & PAYLOAD (Accepting)
  // ============================================================

  @override
  Future<Either<Failure, void>> connectToPeer(String peerId) async {
    try {
      debugPrint('P2P: Requesting connection to $peerId');
      _acceptedPeers.clear();
      await nativeDataSource.requestConnection(peerId);
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Connection Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptConnection(String peerId) async {
    try {
      debugPrint('P2P: Accepting connection from $peerId');
      await nativeDataSource.acceptConnection(peerId);
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Accept Connection Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectFromPeer(String peerId) async {
    try {
      debugPrint('P2P: Disconnecting from $peerId');
      await nativeDataSource.disconnectFromEndpoint(peerId);
      _connectedPeers.removeWhere((p) => p.id == peerId);
      _acceptedPeers.remove(peerId);
      _connectedEndpoints.remove(peerId);
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Disconnect Error: $e'));
    }
  }

  // ============================================================
  // SENDING DATA
  // ============================================================

  @override
  Future<Either<Failure, void>> broadcastMessage(String message) async {
    try {
      for (String peerId in _connectedEndpoints) {
        await nativeDataSource.sendMessage(peerId, message);
      }
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Broadcast Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPayload(String peerId, String message) async {
    try {
      await nativeDataSource.sendMessage(peerId, message);
      return const Right(null);
    } catch (e) {
      debugPrint('P2P: Send payload error: $e');
      return Left(P2PFailure('Send Payload Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendBytesPayload(String peerId, Uint8List bytes) async {
    try {
      String message = String.fromCharCodes(bytes);
      await nativeDataSource.sendMessage(peerId, message);
      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Send Bytes Payload Error: $e'));
    }
  }

  // ============================================================
  // STOP ALL
  // ============================================================

  @override
  Future<Either<Failure, void>> stopAll() async {
    try {
      _isDiscovering = false;
      _isAdvertising = false;
      _retryTimer?.cancel();

      await nativeDataSource.stopNativeDiscovery();
      await nativeDataSource.stopNativeAdvertising();
      await nativeDataSource.stopNativeAllEndpoints();

      _discoveredPeers.clear();
      _connectedPeers.clear();
      _pendingConnectionNames.clear();
      _acceptedPeers.clear();
      _connectedEndpoints.clear();

      _updatePeersStream();

      return const Right(null);
    } catch (e) {
      return Left(P2PFailure('Stop All Error: $e'));
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _updatePeersStream() {
    _peerStreamController.add(List.from(_discoveredPeers));
  }

  void dispose() {
    _retryTimer?.cancel();
    _peerStreamController.close();
    _messageStreamController.close();
  }
}