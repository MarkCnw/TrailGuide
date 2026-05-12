import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:svg_flutter/svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../../domain/entities/trip_history_entity.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadTrips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      context.read<HistoryCubit>().loadTrips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'ประวัติการเดินทาง',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textHigh,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (state is HistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              );
            }
      
            if (state is HistoryEmpty) {
              return _buildEmptyState(context);
            }
      
            if (state is HistoryLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HistoryCubit>().loadTrips();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: state.trips.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(context, state.trips[index]);
                  },
                ),
              );
            }
      
            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  // ✨ Empty State สวยๆ
  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: SvgPicture.asset('assets/Illustration/Group 3.svg')
          ),
          const SizedBox(height: 24),
          Text(
            "ยังไม่มีประวัติทริป",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "เมื่อคุณจบทริปแรก ข้อมูลจะแสดงที่นี่",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  // ✨ การ์ดแสดงประวัติทริป (โชว์ข้อมูลและแผนที่ครบจบในตัว)
  Widget _buildHistoryCard(BuildContext context, TripHistoryEntity trip) {
    final textTheme = Theme.of(context).textTheme;
    final dateText = _formatThaiDate(trip.startedAt);
    final timeText = _formatTime(trip.startedAt);
    final durationText = _formatDuration(trip.startedAt, trip.endedAt);
    
    // แปลงระยะทาง เมตร -> กิโลเมตร
    final distanceKm = (trip.totalDistance / 1000).toStringAsFixed(2);

    // ดึงพิกัดทั้งหมดมาเตรียมวาดเส้น
    List<LatLng> routePoints = [];
    for (int i = 0; i < trip.latitudes.length; i++) {
      routePoints.add(LatLng(trip.latitudes[i], trip.longitudes[i]));
    }

    // คำนวณขอบเขตแผนที่ให้อยู่ตรงกลาง (ถ้ามีเส้นทาง)
    LatLng centerPoint = routePoints.isNotEmpty 
        ? routePoints[routePoints.length ~/ 2] 
        : const LatLng(13.7563, 100.5018); // ค่าเริ่มต้นถ้าไม่มีข้อมูล

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textHigh.withValues(alpha: 0.04), // 🟢 เปลี่ยน withOpacity เป็น withValues ตามที่ Flutter แนะนำ
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // 🗺️ 1. ส่วนแสดงแผนที่ขนาดย่อ (Thumbnail Map)
          if (routePoints.isNotEmpty)
            SizedBox(
              height: 180, 
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: IgnorePointer( 
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: centerPoint,
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.trailguide.app',
                      ),
                      // วาดเส้นทาง (Polyline)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            color: AppColors.primary,
                            strokeWidth: 5.0,
                            // 🟢 ลบส่วน Outline เจ้าปัญหาออกไปเลยครับ เพราะแพ็กเกจใหม่เขาจัดการขอบคนละแบบกัน ใช้เส้นสีทึบธรรมดาก็สวยแล้วครับ
                          ),
                        ],
                      ),
                      // ปักหมุดจุดเริ่มและจุดจบ
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: routePoints.first,
                            child: const Icon(Icons.circle, color: AppColors.success, size: 16),
                          ),
                          Marker(
                            point: routePoints.last,
                            child: const Icon(Icons.stop_circle_rounded, color: AppColors.danger, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // กรณีไม่มีพิกัดถูกบันทึกไว้
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_rounded, color: AppColors.textLow, size: 32),
                  const SizedBox(height: 8),
                  Text("ไม่มีข้อมูลเส้นทาง GPS", style: textTheme.labelMedium?.copyWith(color: AppColors.textLow)),
                ],
              ),
            ),

          // 📝 2. ส่วนข้อมูลสถิติ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // สถิติหลัก (ระยะทาง & เวลา)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ระยะทาง
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ระยะทาง", style: textTheme.labelMedium?.copyWith(color: AppColors.textMedium)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(distanceKm, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textHigh)),
                            const SizedBox(width: 4),
                            Text("กม.", style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textMedium)),
                          ],
                        ),
                      ],
                    ),
                    
                    // เวลาที่ใช้
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("เวลาที่ใช้", style: textTheme.labelMedium?.copyWith(color: AppColors.textMedium)),
                        Text(durationText, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border, thickness: 1.5),
                const SizedBox(height: 16),

                // วันที่ + เวลาเริ่ม
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      "$dateText • เริ่ม $timeText น.",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHigh,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ชื่อ Host
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      "หัวหน้าทีม: ",
                      style: textTheme.labelLarge?.copyWith(color: AppColors.textMedium),
                    ),
                    Expanded(
                      child: Text(
                        trip.hostName,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHigh,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // รายชื่อทีม
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "ลูกทีม (${trip.memberNames.length}): ${trip.memberNames.join(', ')}",
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.textMedium,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helpers =====
  String _formatThaiDate(DateTime dt) {
    const thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final buddhistYear = dt.year + 543;
    return '${dt.day} ${thaiMonths[dt.month - 1]} $buddhistYear';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) {
      return '$hours ชม. $minutes น.'; // 🟢 แก้ไขเรื่องวงเล็บปีกกาเกินความจำเป็น
    }
    return '$minutes นาที';
  }
}