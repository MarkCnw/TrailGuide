package com.markcnw.trail_guide

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*

class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "com.markcnw.trail_guide/p2p_command"
    private val STREAM_CHANNEL = "com.markcnw.trail_guide/p2p_stream"
    private var eventSink: EventChannel.EventSink? = null

    // ตั้งค่าฮาร์ดแวร์ P2P
    private lateinit var connectionsClient: ConnectionsClient
    private val STRATEGY = Strategy.P2P_STAR // โหมด 1 Host ต่อหลาย Member
    private val SERVICE_ID = "com.markcnw.trail_guide"

    // 🚀 ตัวช่วยส่งข้อมูลกลับไปให้ Dart (ต้องวิ่งบน UI Thread เพื่อไม่ให้ Flutter พัง)
    private fun sendToDart(eventData: String) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(eventData)
        }
    }

    // ============================================================
    // CALLBACKS (พนักงานคอยรับเรื่องจากฮาร์ดแวร์)
    // ============================================================

    // 1. พนักงานรับของ (รับข้อความแชท)
    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            if (payload.type == Payload.Type.BYTES) {
                val message = payload.asBytes()?.let { String(it) } ?: return
                println("🤖 Kotlin: ได้รับข้อความจาก $endpointId -> $message")
                // ส่งไป Dart ในรูปแบบ MESSAGE|รหัสเพื่อน|ข้อความ
                sendToDart("MESSAGE|$endpointId|$message")
            }
        }
        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {}
    }

    // 2. พนักงานต้อนรับ (จัดการการเชื่อมต่อ)
    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            println("🤖 Kotlin: มีคนขอเชื่อมต่อ! ชื่อ ${connectionInfo.endpointName} รหัส $endpointId")
            sendToDart("INITIATED|$endpointId|${connectionInfo.endpointName}")
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            when (result.status.statusCode) {
                ConnectionsStatusCodes.STATUS_OK -> {
                    println("🤖 Kotlin: จับมือสำเร็จกับ $endpointId")
                    sendToDart("CONNECTED|$endpointId")
                }
                else -> {
                    println("🤖 Kotlin: การเชื่อมต่อกับ $endpointId ล้มเหลวหรือถูกปฏิเสธ")
                    sendToDart("REJECTED|$endpointId")
                }
            }
        }

        override fun onDisconnected(endpointId: String) {
            println("🤖 Kotlin: ขาดการเชื่อมต่อกับ $endpointId")
            sendToDart("DISCONNECTED|$endpointId")
        }
    }

    // 3. พนักงานสำรวจ (สแกนหาเพื่อน)
    private val endpointDiscoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: DiscoveredEndpointInfo) {
            println("🤖 Kotlin: เจอเพื่อนแล้ว! ชื่อ ${info.endpointName} รหัส $endpointId")
            sendToDart("FOUND|$endpointId|${info.endpointName}")
        }

        override fun onEndpointLost(endpointId: String) {
            println("🤖 Kotlin: เพื่อนหายไปจากระยะ $endpointId")
            sendToDart("LOST|$endpointId")
        }
    }

    // ============================================================
    // FLUTTER ENGINE (ศูนย์รับคำสั่งจาก Dart)
    // ============================================================

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // เสียบปลั๊กเปิดเครื่องวิทยุ
        connectionsClient = Nearby.getConnectionsClient(this)

        // 🎯 ดักฟังคำสั่งจาก Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                
                "startScan" -> {
                    val userName = call.argument<String>("userName") ?: "Unknown User"
                    println("🤖 Kotlin: สั่งเปิดเรดาร์ค้นหา (ชื่อเรา: $userName)")
                    val options = DiscoveryOptions.Builder().setStrategy(STRATEGY).build()
                    connectionsClient.startDiscovery(SERVICE_ID, endpointDiscoveryCallback, options)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("SCAN_ERROR", e.message, null) }
                }
                
                "stopScan" -> {
                    println("🤖 Kotlin: สั่งปิดเรดาร์ค้นหา")
                    connectionsClient.stopDiscovery()
                    result.success(null)
                }
                
                "startAdvertising" -> {
                    val userName = call.argument<String>("userName") ?: "Unknown User"
                    println("🤖 Kotlin: สั่งเปิดห้องกระจายสัญญาณ (ชื่อห้อง: $userName)")
                    val options = AdvertisingOptions.Builder().setStrategy(STRATEGY).build()
                    connectionsClient.startAdvertising(userName, SERVICE_ID, connectionLifecycleCallback, options)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("ADVERTISE_ERROR", e.message, null) }
                }
                
                "stopAdvertising" -> {
                    println("🤖 Kotlin: สั่งปิดห้องกระจายสัญญาณ")
                    connectionsClient.stopAdvertising()
                    result.success(null)
                }
                
                "stopAllEndpoints" -> {
                    println("🤖 Kotlin: สั่งตัดการเชื่อมต่อทั้งหมด")
                    connectionsClient.stopAllEndpoints()
                    result.success(null)
                }
                
                "requestConnection" -> {
                    val peerId = call.argument<String>("peerId") ?: return@setMethodCallHandler
                    println("🤖 Kotlin: สั่งขอจับมือกับ $peerId")
                    connectionsClient.requestConnection("TrailGuide User", peerId, connectionLifecycleCallback)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("REQ_CONN_ERROR", e.message, null) }
                }
                
                "acceptConnection" -> {
                    val peerId = call.argument<String>("peerId") ?: return@setMethodCallHandler
                    println("🤖 Kotlin: สั่งยอมรับการเชื่อมต่อจาก $peerId")
                    connectionsClient.acceptConnection(peerId, payloadCallback)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("ACCEPT_ERROR", e.message, null) }
                }
                
                "disconnectFromEndpoint" -> {
                    val peerId = call.argument<String>("peerId") ?: return@setMethodCallHandler
                    println("🤖 Kotlin: สั่งวางสายจาก $peerId")
                    connectionsClient.disconnectFromEndpoint(peerId)
                    result.success(null)
                }
                
                "sendMessage" -> {
                    val peerId = call.argument<String>("peerId") ?: return@setMethodCallHandler
                    val message = call.argument<String>("message") ?: return@setMethodCallHandler
                    println("🤖 Kotlin: ส่งข้อความ [$message] ไปหา $peerId")
                    val payload = Payload.fromBytes(message.toByteArray())
                    connectionsClient.sendPayload(peerId, payload)
                        .addOnSuccessListener { result.success(null) }
                        .addOnFailureListener { e -> result.error("SEND_ERROR", e.message, null) }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 🎯 เตรียมท่อส่งเสียง (EventChannel) กลับไปหา Dart
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STREAM_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    println("🤖 Kotlin: ท่อ EventChannel พร้อมใช้งาน!")
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }
}