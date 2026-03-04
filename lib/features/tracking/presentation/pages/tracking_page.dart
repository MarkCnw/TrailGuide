import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// P2P & Room
import '../../../../features/p2p/domain/entities/peer_entity.dart';
import '../../../../features/p2p/presentation/bloc/room/room_bloc.dart';
import '../../../../features/p2p/presentation/bloc/room/room_state.dart';
import '../../../../features/p2p/presentation/bloc/room/room_event.dart';
import '../../../../features/p2p/utils/image_helper.dart';

// Location BLoC
import '../bloc/location/location_bloc.dart';
import '../bloc/location/location_event.dart';
import '../bloc/location/location_state.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    // แอนิเมชันสำหรับเรดาร์หมุนวน
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 🚀 สั่ง BLoC เริ่มดูด GPS ทันทีที่เปิดหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(StartTrackingEvent());
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    // 🛑 สั่ง BLoC หยุดดูด GPS เมื่อออกจากหน้านี้
    Future.microtask(() => context.read<LocationBloc>().add(StopTrackingEvent()));
    super.dispose();
  }

  void _showEndTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Adventure?'),
        content: const Text('Are you sure you want to stop tracking and leave the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // สั่งออกจากห้อง
              context.read<RoomBloc>().add(const LeaveRoomEvent());
              context.go('/home'); // กลับไปหน้าแรก
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📡 1. ดักฟัง Location: ถ้ามือถือเราขยับ ให้ส่งพิกัดไปบอกเพื่อนใน RoomBloc ทันที!
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, locationState) {
        if (locationState is LocationTracking) {
          context.read<RoomBloc>().add(
            SendMyLocationEvent(
              latitude: locationState.position.latitude,
              longitude: locationState.position.longitude,
            ),
          );
        }
      },
      // 📡 2. ดักฟัง Room: เพื่อนำรายชื่อและพิกัดเพื่อนมาวาดจอ
      child: BlocConsumer<RoomBloc, RoomState>(
        listener: (context, roomState) {
          if (roomState is RoomClosedByHost || roomState is RoomLeft) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trip ended by host.')),
            );
            context.go('/home');
          }
        },
        builder: (context, roomState) {
          // ดึงรายชื่อคนในทริป
          List<PeerEntity> tripMembers = [];
          if (roomState is RoomCreated) {
            tripMembers = roomState.connectedMembers;
          } else if (roomState is RoomJoined) {
            tripMembers = roomState.allMembers;
          } else if (roomState is RoomTrackingUpdated) { // 🆕 เช็คสถานะนี้ด้วย
            tripMembers = roomState.members; 
          }

          return Scaffold(
            backgroundColor: const Color(0xFF1E1E1E), // พื้นหลังดำเท่ๆ
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: _showEndTripDialog,
              ),
              title: const Text(
                'Trail Radar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.my_location_rounded, color: Colors.greenAccent),
                  onPressed: () {
                    // TODO: Re-center
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                // 📍 แถบโชว์พิกัด GPS ของเราเองด้านบนสุด
                BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, locationState) {
                    if (locationState is LocationError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        color: Colors.red[400],
                        child: Text(locationState.message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                      );
                    }
                    if (locationState is LocationTracking) {
                      final pos = locationState.position;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.black45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'My GPS: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black45,
                      child: const Text('Acquiring GPS Signal...', style: TextStyle(color: Colors.orangeAccent), textAlign: TextAlign.center),
                    );
                  },
                ),

                // ==========================================
                // โซนแสดงผล Radar (ครึ่งบน)
                // ==========================================
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _buildRadarView(tripMembers),
                  ),
                ),

                // ==========================================
                // โซนแสดงรายชื่อเพื่อน (ครึ่งล่าง)
                // ==========================================
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Team Members',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tripMembers.length + 1} Connected', 
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: ListView.separated(
                            itemCount: tripMembers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildMemberCard(tripMembers[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // ปุ่ม SOS
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // TODO: สั่ง RoomBloc ส่ง SOS
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SOS Signal Sent!'), backgroundColor: Colors.red),
                );
              },
              backgroundColor: Colors.red[600],
              icon: const Icon(Icons.emergency_rounded, color: Colors.white),
              label: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  // UI: วาดวงกลมเรดาร์
  Widget _buildRadarView(List<PeerEntity> members) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.greenAccent.withOpacity(0.05),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // วงกลมชั้นใน
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2), width: 1),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.greenAccent.withOpacity(0.2), width: 1),
            ),
          ),
          // เส้นกากบาทตัดกลาง
          Container(width: 320, height: 1, color: Colors.greenAccent.withOpacity(0.2)),
          Container(width: 1, height: 320, color: Colors.greenAccent.withOpacity(0.2)),

          // เข็มเรดาร์หมุน (Sweep Animation)
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _radarController.value * 2 * math.pi,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.greenAccent.withOpacity(0.0),
                        Colors.greenAccent.withOpacity(0.5),
                      ],
                      stops: const [0.5, 1.0],
                      startAngle: 0.0,
                      endAngle: math.pi / 2,
                    ),
                  ),
                ),
              );
            },
          ),

          // จุดตำแหน่งของตัวเอง (ตรงกลางเสมอ)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.blueAccent, blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: const Center(
              child: Icon(Icons.navigation_rounded, size: 12, color: Colors.white),
            ),
          ),

          // TODO: อนาคตจะนำพิกัดเพื่อนมาคำนวณวาดจุดตรงนี้ (Phase 3)
        ],
      ),
    );
  }

  // UI: การ์ดแสดงเพื่อน
  Widget _buildMemberCard(PeerEntity member) {
    final imageBytes = ImageHelper.decodeBase64(member.imageBase64);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: member.isHost ? Colors.green[100] : Colors.blue[100],
            backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
            child: imageBytes == null
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: member.isHost ? Colors.green[700] : Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (member.isHost) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded, size: 16, color: Colors.amber[600]),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                
                // 📍 แสดงพิกัดล่าสุดที่รับจากเพื่อน
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      member.latitude != null && member.longitude != null
                          ? 'Lat: ${member.latitude!.toStringAsFixed(4)}, Lng: ${member.longitude!.toStringAsFixed(4)}'
                          : 'Waiting for GPS...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // เข็มทิศเล็กๆ
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
            child: Transform.rotate(
              angle: math.pi / 4, // TODO: ใส่ค่า Heading จริงตรงนี้
              child: Icon(Icons.navigation_rounded, color: Colors.green[600], size: 20),
            ),
          ),
        ],
      ),
    );
  }
}