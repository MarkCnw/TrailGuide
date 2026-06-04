import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.danger,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMedium),
                    ),
                  ],
                ),
              );
            }

            if (state is HistoryEmpty) {
              return _buildEmptyState(context);
            }

            if (state is HistoryLoaded) {
              final trips = state.trips;
              // 1. 🔢 หาจำนวนทริปทั้งหมด
              final int totalTrips = trips.length;
              // 2. 🛣️ หาระยะทางรวม (ใช้ลูป for-in เหมือนหยอดกระปุก)
              double totalDistance = 0.0;
              for (var trip in trips) {
                // ดึงค่าระยะทางของแต่ละทริปมาบวกสะสม
                double distance = trip.totalDistance;
                if (!distance.isNaN && !distance.isInfinite) {
                  totalDistance += distance;
                }
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HistoryCubit>().loadTrips();
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  // 🟢 2. ใช้ความยาวจาก trips ปกติ
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    // 🟢 3. ดึงค่ามาใช้ได้เลย ลำดับจะถูกต้อง (ใหม่ -> เก่า) ตามที่ Isar จัดมาให้
                    final trip = trips[index];
                    return _buildCleanHistoryCard(context, trip);
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
            child: SvgPicture.asset('assets/Illustration/Group 3.svg'),
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

  // ✨ การ์ดแสดงประวัติทริป (ดีไซน์ใหม่แบบ Clean + SVG Icons)
  Widget _buildCleanHistoryCard(
    BuildContext context,
    TripHistoryEntity trip,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final dateText = _formatThaiDate(trip.startedAt);
    final timeText = _formatTime(trip.startedAt);
    final durationText = _formatDuration(trip.startedAt, trip.endedAt);

    double safeDistance = trip.totalDistance;
    if (safeDistance.isNaN || safeDistance.isInfinite) {
      safeDistance = 0.0;
    }

    String distanceValue;
    String distanceUnit;

    if (safeDistance < 1000) {
      distanceValue = safeDistance.toStringAsFixed(0);
      distanceUnit = "เมตร";
    } else {
      distanceValue = (safeDistance / 1000).toStringAsFixed(2);
      distanceUnit = "กม.";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📅 1. ส่วนหัว: วันที่ และ เวลาเริ่ม
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    Text(
                      dateText,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                "เริ่ม $timeText น.",
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 📊 2. ส่วนสถิติ: ระยะทาง และ เวลา
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  context,
                  icon: Icons.route_rounded,
                  label: "ระยะทาง",
                  value: distanceValue,
                  unit: distanceUnit,
                  iconColor: AppColors.success,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildStatColumn(
                  context,
                  icon: Icons.timer_rounded,
                  label: "เวลาที่ใช้",
                  value: durationText,
                  unit: "",
                  iconColor: AppColors.info,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // 👥 3. ส่วนข้อมูลสมาชิกทีม (อัปเดตเป็น SVG)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- บรรทัดหัวหน้าทีม ---
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/app/Crown1.svg', // 🟢 1. เปลี่ยนชื่อไฟล์ SVG ให้ตรงกับของคุณ
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "หัวหน้าทีม: ",
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    trip.hostName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHigh,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --- บรรทัดลูกทีม ---
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // ให้ไอคอนอยู่ชิดบรรทัดบนสุดเผื่อรายชื่อยาว
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                    ), // ดันไอคอนลงมานิดนึงให้พอดีกับ Text
                    child: SvgPicture.asset(
                      'assets/icons/app/joinnn.svg', // 🟢 2. เปลี่ยนชื่อไฟล์ SVG ให้ตรงกับของคุณ
                      color: Colors.blue,
                      width: 18,
                      height: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "ลูกทีม: ${trip.memberNames.isEmpty ? '-' : trip.memberNames.join(', ')}",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Widget ย่อยสำหรับสร้างกล่องสถิติ =====
  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color iconColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textHigh,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ===== Helpers สำหรับจัดการวันที่และเวลา =====
  String _formatThaiDate(DateTime dt) {
    const thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
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

    // ถ้าเวลาไม่ถึง 1 นาที ให้แสดงว่า 1 นาที (เพื่อไม่ให้ขึ้น 0 นาที)
    if (hours == 0 && minutes == 0) {
      return '1 นาที';
    }

    if (hours > 0) {
      return '$hours ชม. $minutes น.';
    }
    return '$minutes นาที';
  }
}
