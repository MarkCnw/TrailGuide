import 'dart:math' as math;
import 'dart:typed_data'; // 🟢 เพิ่มสำหรับการทำ cache รูปภาพ
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';
import 'package:trail_guide/core/constants/app_colors.dart';
import 'package:trail_guide/core/utils/location_calculator.dart';

// P2P & Room
import '../../domain/entities/peer_entity.dart';
import '../bloc/room/room_bloc.dart';
import '../bloc/room/room_state.dart';
import '../bloc/room/room_event.dart';
import '../../utils/image_helper.dart';

// Location BLoC
import '../../../tracking/presentation/bloc/location/location_bloc.dart';
import '../../../tracking/presentation/bloc/location/location_event.dart';
import '../../../tracking/presentation/bloc/location/location_state.dart';

// History
import '../../../history/presentation/cubit/history_cubit.dart';
import '../../../history/domain/entities/trip_history_entity.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  // 🌟 ประกาศตัวแปรเก็บ LocationBloc เพื่อป้องกันบัค context พังตอนสลับหน้า
  late final LocationBloc _locationBloc;

  // 🟢 1. เพิ่มตัวแปรนี้: เอาไว้จำว่าใครโดนเตือนระยะ 80m ไปแล้วบ้าง
  final Set<String> _warnedMembers = {};

  // 🧭 Compass Smoothing: ใช้ low-pass filter เพื่อลดการกระตุกของเข็มทิศ
  double _smoothedHeading = 0.0;
  static const double _headingSmoothingFactor =
      0.15; // ค่ายิ่งน้อย = ยิ่ง smooth (แต่ช้า)

  // 🖼️ Image Cache: เก็บรูปที่แปลงแล้วไว้ จะได้ไม่ต้องแปลงใหม่ทุกเฟรม (แก้ปัญหารูปกระพริบเวลาเข็มทิศหมุน)
  final Map<String, Uint8List?> _imageCache = {};

  // 📝 Trip History: เก็บข้อมูลทริปไว้บันทึกตอนจบ
  DateTime? _tripStartTime;
  String _tripHostName = '';
  List<String> _tripMemberNames = [];
  // 📝 🟢 ตัวแปรสำหรับเก็บระยะทางและเส้นทาง (แบบ Strava)
  double _totalDistance = 0.0;
  final List<double> _routeLatitudes = [];
  final List<double> _routeLongitudes = [];

  
  @override
  void initState() {
    super.initState();

    // ดึงค่ามาเก็บไว้ในตัวแปรตั้งแต่เริ่มสร้างหน้าจอ
    _locationBloc = context.read<LocationBloc>();

    // 🚀 เริ่มดูด GPS เมื่อเปิดแท็บนี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationBloc.add(StartTrackingEvent());
    });

    // 🟢 FIX: จับ state เริ่มต้นทันที! (เพราะ BlocConsumer.listener จะไม่ fire สำหรับ state ปัจจุบัน)
    final currentState = context.read<RoomBloc>().state;
    if (currentState is RoomTripStarted) {
      _tripStartTime = DateTime.now();
      final roomBloc = context.read<RoomBloc>();
      _tripHostName = roomBloc.hostName;
      _tripMemberNames = currentState.members.map((m) => m.name).toList();
      print('📝 [TripHistory] initState จับ state ได้ → Host: $_tripHostName, Members: $_tripMemberNames, StartTime: $_tripStartTime');
    } else {
      print('📝 [TripHistory] initState → state ปัจจุบันคือ: ${currentState.runtimeType} (ยังไม่ใช่ RoomTripStarted)');
    }
  }

  // 🟢 2. ฟังก์ชันเช็กระยะห่างเพื่อน (พร้อมระบบ Cooldown กันแจ้งเตือนสแปม)
  void _checkMemberDistances(
    List<PeerEntity> members,
    double myLat,
    double myLng,
  ) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme สำหรับ SnackBar

    for (var member in members) {
      if (member.latitude != null &&
          member.longitude != null &&
          member.isActive) {
        double distance = LocationCalculator.calculateDistance(
          myLat,
          myLng,
          member.latitude!,
          member.longitude!,
        );

        // ถ้าห่างเกิน 80 เมตร และยังไม่เคยแจ้งเตือน
        if (distance >= 80.0) {
          if (!_warnedMembers.contains(member.id)) {
            _warnedMembers.add(member.id); // จำไว้ว่าเตือนคนนี้ไปแล้ว

            // รอให้หน้าจอวาดเสร็จก่อน แล้วค่อยเด้ง SnackBar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ระวัง! ${member.name} อยู่ห่างเกิน 80 เมตร',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            });
          }
        }
        // ถ้าระยะกลับมาใกล้กว่า 60 เมตร -> ให้รีเซ็ตค่าเพื่อเปิดโอกาสให้เตือนใหม่ได้ในอนาคต
        else if (distance < 60.0) {
          _warnedMembers.remove(member.id);
        }
      }
    }
  }

  /// 🧭 Low-pass filter สำหรับ smooth ค่าองศา (จัดการ wrap-around 0°/360° ด้วย)
  double _smoothAngle(double current, double target, double factor) {
    double delta = target - current;
    while (delta > 180) delta -= 360;
    while (delta < -180) delta += 360;

    double result = current + delta * factor;
    return (result % 360 + 360) % 360;
  }

  /// 📝 บันทึกประวัติทริปลง Isar เมื่อทริปจบ
void _saveTripHistory(BuildContext context) {
    if (_tripStartTime == null) return;

    final trip = TripHistoryEntity(
      id: 0, 
      hostName: _tripHostName,
      memberNames: _tripMemberNames,
      startedAt: _tripStartTime!,
      endedAt: DateTime.now(),
      totalDistance: _totalDistance, // 🟢 ใส่ระยะทางที่คำนวณได้
      latitudes: _routeLatitudes, // 🟢 ใส่พิกัดเส้นทางทั้งหมด
      longitudes: _routeLongitudes, // 🟢 ใส่พิกัดเส้นทางทั้งหมด
    );

    context.read<HistoryCubit>().saveTripRecord(trip);
    
    // 🟢 ล้างค่าเส้นทางเก่าทิ้งเผื่อเริ่มทริปใหม่
    _tripStartTime = null;
    _totalDistance = 0.0;
    _routeLatitudes.clear();
    _routeLongitudes.clear();
  }
  @override
  void dispose() {
    // 🌟 สั่งหยุด GPS ผ่านตัวแปรตรงๆ ไม่มี Future.microtask หรือ context แล้ว
    _locationBloc.add(StopTrackingEvent());
    super.dispose();
  }

  // 🔧 Bug #6 Fix: ดึง BLoC reference ก่อนเข้า dialog builder เพื่อไม่ใช้ dialog context
  void _showEndTripDialog() {
    final roomBloc = context.read<RoomBloc>();
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'สิ้นสุดการเดินทาง',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการหยุดการติดตามและออกจากกลุ่ม?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'ยกเลิก',
              style: textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              if (roomBloc.isHost) {
                roomBloc.add(
                  const CloseRoomEvent(reason: 'Host ยุติการเดินทางแล้ว.'),
                );
              } else {
                roomBloc.add(const LeaveRoomEvent());
              }

              _locationBloc.add(StopTrackingEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'จบทริป',
              style: textTheme.labelLarge?.copyWith(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme กลาง

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
      child: BlocConsumer<RoomBloc, RoomState>(
        buildWhen: (previous, current) {
          return current is! RoomMemberLeft &&
              current is! RoomEmergencyState;
        },
        listener: (context, roomState) {
          if (roomState is RoomClosedByHost) {
            _saveTripHistory(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(roomState.reason),
                backgroundColor: Colors.red[600],
              ),
            );
            context.go('/home');
          } else if (roomState is RoomLeft) {
            _saveTripHistory(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('คุณออกจากการเดินทาง'),
                backgroundColor: Colors.orange[600],
              ),
            );
            context.go('/home');
          } else if (roomState is RoomTripStarted) {
            _tripStartTime = DateTime.now();
            final roomBloc = context.read<RoomBloc>();
            _tripHostName = roomBloc.hostName;
            _tripMemberNames = roomState.members
                .map((m) => m.name)
                .toList();
          } else if (roomState is RoomMemberLeft) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${roomState.memberName} ขาดการเชื่อมต่อ!',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (roomState is RoomEmergencyState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.red[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'SOS ALERT!',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  '${roomState.senderId} ต้องการความช่วยเหลือด่วน!\nโปรดเช็กพิกัดบนเรดาร์และรีบไปหาทันที!',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[900],
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'รับทราบ',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, roomState) {
          // ==========================================
          // 🟢 STATE 3: ทริปเริ่มแล้ว (Active)
          // ==========================================
          if (roomState is RoomTripStarted ||
              roomState is RoomTrackingUpdated) {
            return _buildActiveRadar(context, roomState);
          }

          // ==========================================
          // 🛑 STATE 1: ยังไม่มีห้อง (Offline / Initial)
          // ==========================================
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // 🖼️ ภาพประกอบตรงกลาง
                    SvgPicture.asset(
                      'assets/Illustration/vf.svg', 
                      width: 220, 
                      height: 220,
                    ),
                    const SizedBox(height: 40),

                    // 📝 ข้อความ Headline
                    Text(
                      'เรดาห์ ออฟไลน์',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 30,
                        color: AppColors.textHigh,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      
                      'สร้างห้องเพื่อเป็นผู้นำทาง หรือเข้าร่วม\nเรดาร์ของเพื่อนเพื่อเริ่มการเดินทาง',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.5,
                        fontSize: 15
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    // 🟢 เปลี่ยนปุ่มเป็นแนวนอนซ้าย-ขวา
                    Row(
                      children: [
                        // 🔘 ปุ่มซ้าย: สร้างกลุ่ม (Host Room)
                        Expanded(
                          child: InkWell(
                            onTap: () => context.go('/lobby'),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: SvgPicture.asset(
                                      'assets/icons/app/Crown1.svg',
                                      width: 40,
                                      height: 40,
                                      colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'สร้างกลุ่ม',
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16), // ระยะห่างระหว่าง 2 ปุ่ม

                        // 🔘 ปุ่มขวา: เข้าร่วมกลุ่ม (Join Room)
                        Expanded(
                          child: InkWell(
                            onTap: () => context.go('/scan'),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.border, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: SvgPicture.asset(
                                      'assets/icons/app/joinnn.svg',
                                      width: 40,
                                      height: 40,
                                      colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'เข้าร่วมกลุ่ม',
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textHigh),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2), // ดันให้องค์ประกอบอยู่ตรงกลางพอดี
                  ],
                ),
              ),
            ),
          ); 
        },
      ),
    );
  }

  // ==========================================
  // 🟢 ฟังก์ชันวาดหน้าจอ Active Radar ตัวจริง
  // ==========================================
  Widget _buildActiveRadar(BuildContext context, RoomState roomState) {
    final myDeviceId = context.read<RoomBloc>().deviceId;
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme กลาง

    List<PeerEntity> tripMembers = [];
    if (roomState is RoomTripStarted) {
      tripMembers = roomState.members
          .where((m) => m.id != myDeviceId)
          .toList();
    } else if (roomState is RoomTrackingUpdated) {
      tripMembers = roomState.members
          .where((m) => m.id != myDeviceId)
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.power_settings_new_rounded,
            color: Colors.redAccent,
          ),
          onPressed: _showEndTripDialog,
        ),
        title: Text(
          'Trail Radar',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textHigh,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final roomBloc = context.read<RoomBloc>();
          final locState = _locationBloc.state;

          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Emergency SOS',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'คุณแน่ใจหรือไม่ว่าต้องการส่งสัญญาณฉุกเฉินให้เพื่อนทุกคนในทีม?\n(ใช้ในกรณีฉุกเฉินเท่านั้น)',
                style: textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'ยกเลิก',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    double currentLat = 0.0;
                    double currentLng = 0.0;

                    if (locState is LocationTracking) {
                      currentLat = locState.position.latitude;
                      currentLng = locState.position.longitude;
                    }

                    roomBloc.add(
                      RoomSendSOSEvent(
                        latitude: currentLat,
                        longitude: currentLng,
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'ส่งสัญญาณ SOS ฉุกเฉินเรียบร้อย!',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.red[600],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    'ส่ง SOS',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.red[600],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SvgPicture.asset('assets/icons/app/hand.svg',width: 40,height: 40,color: Colors.white,)
      ),

      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, locationState) {
          if (locationState is LocationTracking) {
            final lat = locationState.position.latitude;
            final lng = locationState.position.longitude;

            // 🟢 1. ส่งพิกัดไปให้เพื่อนในห้อง (โค้ดเดิมของคุณ)
            context.read<RoomBloc>().add(
              SendMyLocationEvent(latitude: lat, longitude: lng),
            );

            // 🟢 2. เช็กระยะห่างเพื่อนเพื่อเตือน (โค้ดเดิมของคุณ)
            if (tripMembers.isNotEmpty) {
              _checkMemberDistances(tripMembers, lat, lng);
            }

            // 🟢 3. *** ระบบเก็บระยะทางและเส้นทาง (ใหม่!) ***
            // จะเก็บเส้นทางก็ต่อเมื่อ "ทริปเริ่มแล้ว" เท่านั้น
            if (_tripStartTime != null) {
              if (_routeLatitudes.isEmpty) {
                // ถ้าเป็นจุดแรกสุด ก็เก็บเลย
                _routeLatitudes.add(lat);
                _routeLongitudes.add(lng);
              } else {
                // ถอยไปดูจุดล่าสุดที่เราเดินผ่านมา
                final lastLat = _routeLatitudes.last;
                final lastLng = _routeLongitudes.last;
                
                // คำนวณว่าพิกัดใหม่ ขยับจากจุดเดิมกี่เมตร
                final dist = LocationCalculator.calculateDistance(lastLat, lastLng, lat, lng);
                
                // 💡 กรอง Noise: ถ้าเดินขยับเกิน 2 เมตร ถึงจะนับว่าเดินจริง (ป้องกัน GPS แกว่งตอนยืนเฉยๆ)
                if (dist > 2.0) {
                  _routeLatitudes.add(lat);
                  _routeLongitudes.add(lng);
                  _totalDistance += dist; // บวกรวมระยะทางเข้าไป!
                }
              }
            }
          }
        },
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            double? myLat;
            double? myLng;

            if (locationState is LocationTracking) {
              myLat = locationState.position.latitude;
              myLng = locationState.position.longitude;
            }

            return StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final rawHeading = snapshot.data?.heading ?? 0.0;
                _smoothedHeading = _smoothAngle(
                  _smoothedHeading,
                  rawHeading,
                  _headingSmoothingFactor,
                );
                final double myHeading = _smoothedHeading;

                return Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: _buildRadarCircle(
                          context, // 🟢 ส่ง Context เข้าไปใช้งาน Theme
                          tripMembers,
                          myLat,
                          myLng,
                          myHeading,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 24,
                          left: 24,
                          right: 24,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'สมาชิกในทีม',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${tripMembers.length + 1} เชื่อมต่อ',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: tripMembers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildMemberCard(
                                    context, // 🟢 ส่ง Context
                                    tripMembers[index],
                                    myLat,
                                    myLng,
                                    myHeading,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // 🟢 ฟังก์ชันวาดวงกลมเรดาร์ (รับ BuildContext เพิ่มเติม)
  Widget _buildRadarCircle(
    BuildContext context,
    List<PeerEntity> members,
    double? myLat,
    double? myLng,
    double myHeading,
  ) {
    const double radarSize = 320.0;
    const double centerOffset = radarSize / 2;
    const double maxDistanceMeters = 200.0;

    List<Widget> radarBlips = [];

    if (myLat != null && myLng != null) {
      for (var member in members) {
        if (member.latitude != null && member.longitude != null) {
          double distance = LocationCalculator.calculateDistance(
            myLat,
            myLng,
            member.latitude!,
            member.longitude!,
          );

          double drawDistance = distance > maxDistanceMeters
              ? maxDistanceMeters
              : distance;
          double scaledRadius =
              (drawDistance / maxDistanceMeters) * centerOffset;

          double bearing = LocationCalculator.calculateBearing(
            myLat,
            myLng,
            member.latitude!,
            member.longitude!,
          );

          double relativeBearing = bearing - myHeading;
          double mathAngle = (relativeBearing - 90) * (math.pi / 180);

          double x = centerOffset + (scaledRadius * math.cos(mathAngle));
          double y = centerOffset + (scaledRadius * math.sin(mathAngle));

          radarBlips.add(
            Positioned(
              left: x - 14,
              top: y - 14,
              child: _buildRadarDot(context, member),
            ),
          );
        }
      }
    }

    return SizedBox(
      width: radarSize,
      height: radarSize,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: radarSize * 0.35,
              height: radarSize * 0.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: radarSize * 0.65,
              height: radarSize * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: radarSize * 0.95,
              height: radarSize * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),

          ...radarBlips,

          Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[600]!.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.navigation_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔴 ฟังก์ชันสร้างจุด 1 จุดบนเรดาร์
  Widget _buildRadarDot(BuildContext context, PeerEntity member) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme กลาง
    final color = member.isHost ? Colors.amber[700]! : Colors.green[700]!;

    return Tooltip(
      message: member.name,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // 🟢 ฟังก์ชันสร้างการ์ดรายชื่อเพื่อน 
  Widget _buildMemberCard(
    BuildContext context,
    PeerEntity member,
    double? myLat,
    double? myLng,
    double myHeading,
  ) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme กลาง

    if (!_imageCache.containsKey(member.id)) {
      _imageCache[member.id] = ImageHelper.decodeBase64(
        member.imageBase64,
      );
    }
    final imageBytes = _imageCache[member.id];

    String distanceText = 'รอสัญญาณ GPS...';
    double bearingAngle = 0.0;
    bool canCalculate = false;
    bool isTooClose = false;

    if (myLat != null &&
        myLng != null &&
        member.latitude != null &&
        member.longitude != null) {
      canCalculate = true;

      final distanceInMeters = LocationCalculator.calculateDistance(
        myLat,
        myLng,
        member.latitude!,
        member.longitude!,
      );

      if (distanceInMeters >= 1000) {
        distanceText =
            '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
      } else {
        distanceText = '${distanceInMeters.toStringAsFixed(0)} m';
      }

      isTooClose = distanceInMeters < 10.0;

      final bearingInDegrees = LocationCalculator.calculateBearing(
        myLat,
        myLng,
        member.latitude!,
        member.longitude!,
      );
      final relativeBearing = bearingInDegrees - myHeading;
      bearingAngle = relativeBearing * (math.pi / 180);
    }

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
            backgroundColor: member.isHost
                ? Colors.green[100]
                : Colors.blue[100],
            backgroundImage: imageBytes != null
                ? MemoryImage(imageBytes)
                : null,
            child: imageBytes == null
                ? Text(
                    member.name.isNotEmpty
                        ? member.name[0].toUpperCase()
                        : '?',
                    style: textTheme.titleMedium?.copyWith(
                      color: member.isHost
                          ? Colors.green[700]
                          : Colors.blue[700],
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
                    Text(
                      member.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (member.isHost) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      canCalculate
                          ? Icons.social_distance_rounded
                          : Icons.location_searching_rounded,
                      size: 14,
                      color: canCalculate
                          ? Colors.green[600]
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        distanceText,
                        style: textTheme.bodySmall?.copyWith(
                          color: canCalculate
                              ? Colors.grey[800]
                              : Colors.grey[500],
                          fontWeight: canCalculate
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: canCalculate ? Colors.green[50] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (canCalculate && !isTooClose) ? bearingAngle : 0.0,
              child: Icon(
                isTooClose
                    ? Icons.adjust_rounded
                    : (canCalculate
                          ? Icons.navigation_rounded
                          : Icons.location_searching_rounded),
                color: canCalculate ? Colors.green[600] : Colors.grey[400],
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}