import 'package:flutter/services.dart';

abstract class P2PNativeDataSource {
  // กลุ่มค้นหา
  Future<void> startNativeDiscovery(String userName);
  Future<void> stopNativeDiscovery();

  // กลุ่มสร้างห้อง
  Future<void> startNativeAdvertising(String userName);
  Future<void> stopNativeAdvertising();
  Future<void> stopNativeAllEndpoints();

  // กลุ่มจัดการการเชื่อมต่อ
  Future<void> requestConnection(String peerId);
  Future<void> acceptConnection(String peerId);
  Future<void> disconnectFromEndpoint(String peerId);
  
  // กลุ่มส่งข้อความ (ใช้ตัวเดียวครอบคลุมทั้งหมด)
  Future<void> sendMessage(String peerId, String message);

  // ท่อดักฟังข้อความ
  Stream<String> get messageStream;
}

class P2PNativeDataSourceImpl implements P2PNativeDataSource {
  static const MethodChannel _methodChannel = MethodChannel(
    'com.markcnw.trail_guide/p2p_command',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.markcnw.trail_guide/p2p_stream',
  );

  // ==========================================
  // DISCOVERY
  // ==========================================

  @override
  Future<void> startNativeDiscovery(String userName) async {
    await _methodChannel.invokeMethod('startScan', {'userName': userName});
  }

  @override
  Future<void> stopNativeDiscovery() async {
    await _methodChannel.invokeMethod('stopScan');
  }

  // ==========================================
  // ADVERTISING
  // ==========================================

  @override
  Future<void> startNativeAdvertising(String userName) async {
    await _methodChannel.invokeMethod('startAdvertising', {
      'userName': userName,
    });
  }

  @override
  Future<void> stopNativeAdvertising() async {
    await _methodChannel.invokeMethod('stopAdvertising');
  }

  @override
  Future<void> stopNativeAllEndpoints() async {
    await _methodChannel.invokeMethod('stopAllEndpoints');
  }

  // ==========================================
  // CONNECTION MANAGEMENT
  // ==========================================

  @override
  Future<void> requestConnection(String peerId) async {
    await _methodChannel.invokeMethod('requestConnection', {
      'peerId': peerId,
    });
  }

  @override
  Future<void> acceptConnection(String peerId) async {
    await _methodChannel.invokeMethod('acceptConnection', {
      'peerId': peerId,
    });
  }

  @override
  Future<void> disconnectFromEndpoint(String peerId) async {
    await _methodChannel.invokeMethod('disconnectFromEndpoint', {
      'peerId': peerId,
    });
  }

  // ==========================================
  // SEND MESSAGE
  // ==========================================

  @override
  Future<void> sendMessage(String peerId, String message) async {
    await _methodChannel.invokeMethod('sendMessage', {
      'peerId': peerId,
      'message': message,
    });
  }

  // ==========================================
  // STREAM (LISTENER)
  // ==========================================

  @override
  Stream<String> get messageStream {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => event.toString(),
    );
  }
}