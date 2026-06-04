import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

import 'package:torch_light/torch_light.dart';
// 🟢 เอา import 'package:google_fonts/google_fonts.dart'; ออกไปแล้วเพราะเราจะดึงจาก Theme แทน

// 🟢 Import Design System
import '../../../../core/constants/app_colors.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';

// 🟢 Import Location BLoC (Clean Architecture)
import '../../../tracking/presentation/bloc/location/location_bloc.dart';
import '../../../tracking/presentation/bloc/location/location_event.dart';
import '../../../tracking/presentation/bloc/location/location_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  // 🔦 Flashlight State (เอาไว้ใน UI ได้เพราะเป็นแค่ Toggler ทั่วไป)
  bool _isFlashlightOn = false;
  bool _hasFlashlight = false;

  @override
  void initState() {
    super.initState();
    _checkFlashlightAvailability();

    // 🚀 สั่งให้ BLoC เริ่มดูด GPS ตั้งแต่เข้าหน้านี้ (Clean Architecture)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(StartTrackingEvent());
    });
  }

  // ---------------------------------------------------------------------------
  // 🔦 FLASHLIGHT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _checkFlashlightAvailability() async {
    try {
      setState(() {
        _hasFlashlight = true;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleFlashlight() async {
    try {
      if (_isFlashlightOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
      });
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ไม่สามารถเปิดไฟฉายได้ ⚠️'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🎨 UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // 🟢 ประกาศเรียกใช้งาน TextTheme จากส่วนกลาง
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: (Colors.white),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // === CLEAN APP BAR ===
          SliverAppBar(
            expandedHeight: 100.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize:  Size.fromHeight(1.0.h),
              child: Container(color: Colors.transparent, height: 1.0.h),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:  EdgeInsets.only(
                left: 24.w,
                bottom: 15.h,
                right: 24.w,
              ),
              title: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  if (state is OnboardingLoaded) {
                    final user = state.profile;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // รูปโปรไฟล์
                        Container(
                          margin:  EdgeInsets.only(top: 2.h),
                          padding:  EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: CircleAvatar(
                            
                            radius: 20.r,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            backgroundImage: user.imagePath != null
                                ? FileImage(File(user.imagePath!))
                                : null,
                            child: user.imagePath == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 24.sp,
                                    color: Colors.white.withOpacity(0.7),
                                  )
                                : null,
                          ),
                        ),
                         SizedBox(width: 12.w),

                        // ชื่อ และ Badge
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'สวัสดีนักเดินทาง',
                                // 🟢 ดึง Style จาก Theme
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                user.nickname,
                                // 🟢 ดึง Style จาก Theme
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                               SizedBox(height: 6.h),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // === BODY CONTENT ===
          SliverToBoxAdapter(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 24.h),

                  // 🛠️ DASHBOARD CARD (Flashlight + GPS)
                  Container(
                    height: 86.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textHigh.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 🔦 Flashlight Button
                        Expanded(
                          child: InkWell(
                            borderRadius:  BorderRadius.horizontal(
                              left: Radius.circular(20.r),
                            ),
                            onTap: _hasFlashlight
                                ? _toggleFlashlight
                                : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isFlashlightOn
                                      ? Icons.flashlight_on_rounded
                                      : Icons.flashlight_off_rounded,
                                  color: _isFlashlightOn
                                      ? AppColors.warning
                                      : AppColors.textLow,
                                  size: 28.sp,
                                ),
                                 SizedBox(height: 6.h),
                                Text(
                                  _isFlashlightOn
                                      ? "ปิดไฟฉาย"
                                      : "เปิดไฟฉาย",
                                  // 🟢 ดึง Style จาก Theme
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _isFlashlightOn
                                        ? AppColors.warning
                                        : AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Divider
                        Container(
                          width: 1.5.w,
                          height: 40.h,
                          color: AppColors.border,
                        ),

                        // 📡 GPS Signal (🔗 เชื่อมต่อกับ LocationBloc แบบ Clean Arch!)
                        Expanded(
                          child: BlocBuilder<LocationBloc, LocationState>(
                            builder: (context, state) {
                              int bars = 0;
                              String statusText = "ค้นหาพิกัด...";
                              Color signalColor = AppColors.textLow;

                              if (state is LocationTracking) {
                                double accuracy = state.position.accuracy;
                                if (accuracy <= 10) {
                                  bars = 4;
                                  statusText = "GPS: ยอดเยี่ยม";
                                  signalColor = AppColors.success;
                                } else if (accuracy <= 25) {
                                  bars = 3;
                                  statusText = "GPS: ดี";
                                  signalColor = AppColors.success
                                      .withOpacity(0.8);
                                } else if (accuracy <= 50) {
                                  bars = 2;
                                  statusText = "GPS: ปานกลาง";
                                  signalColor = AppColors.warning;
                                } else {
                                  bars = 1;
                                  statusText = "GPS: อ่อน";
                                  signalColor = AppColors.danger;
                                }
                              } else if (state is LocationError) {
                                bars = 0;
                                statusText = "ไม่มีพิกัด";
                                signalColor = AppColors.danger;
                              }

                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.satellite_alt_rounded,
                                        color: signalColor,
                                        size: 20.sp,
                                      ),
                                       SizedBox(width: 8.w),
                                      _buildSignalBar(
                                        height: 6.h,
                                        isActive: bars >= 1,
                                        activeColor: signalColor,
                                      ),
                                      _buildSignalBar(
                                        height: 10.h,
                                        isActive: bars >= 2,
                                        activeColor: signalColor,
                                      ),
                                      _buildSignalBar(
                                        height: 14.h,
                                        isActive: bars >= 3,
                                        activeColor: signalColor,
                                      ),
                                      _buildSignalBar(
                                        height: 18.h,
                                        isActive: bars >= 4,
                                        activeColor: signalColor,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    statusText,
                                    // 🟢 ดึง Style จาก Theme
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // --- หัวข้อวิธีใช้งาน ---
                  Text(
                    "เริ่มต้นการใช้งาน",
                    // 🟢 ดึง Style หลักจาก Theme 
                    style: textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.h),

                  // 📦 รวมทุก Step ไว้ในการ์ดใบเดียว
                  Container(
                    padding:  EdgeInsets.all(5.w),

                    child: Column(
                      children: [
                        _buildStepRow(
                          stepNumber: '1',
                          title: 'สร้างกลุ่ม',
                          description:
                              'กด สร้างกลุ่ม เพื่อสร้างห้องและรอเพื่อนเข้าร่วม',
                          iconColor: Colors.amber,
                          svgPath: 'assets/icons/app/Crown.svg',
                        ),
                        _buildStepRow(
                          stepNumber: '2',
                          title: 'เข้าร่วมทีม',
                          description:
                              'กด เข้าร่วมทีม เพื่อค้นหาห้องเพื่อนที่อยู่ใกล้เคียง',
                          iconColor: AppColors.info,
                          svgPath: 'assets/icons/app/joinn.svg',
                        ),
                        _buildStepRow(
                          stepNumber: '3',
                          title: 'เปิดเรดาร์นำทาง',
                          description:
                              'ดูตำแหน่งและระยะห่างของเพื่อนแบบ Real-time',
                          iconColor: AppColors.warning,
                          svgPath: 'assets/icons/app/Compass.svg',
                        ),
                        _buildStepRow(
                          stepNumber: '4',
                          title: 'สถานการณ์ฉุกเฉิน',
                          description:
                              'กดปุ่ม ขอความช่วยเหลือ สีแดง เพื่อแจ้งเตือนพิกัดไปยังทุกคน',
                          iconColor: AppColors.danger,
                          isDanger: true,
                          isLast: true,
                          svgPath: 'assets/icons/app/hand.svg',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🪄 Widget สร้างแท่งสัญญาณ
  Widget _buildSignalBar({
    required double height,
    required bool isActive,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin:  EdgeInsets.symmetric(horizontal: 1.5.w),
      width: 4.w,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? activeColor : AppColors.border,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  // 📖 🔧 เปลี่ยนการใช้ Icon ธรรมดาเป็น SVG (ดึงฟอนต์จาก Theme)
  Widget _buildStepRow({
    required String stepNumber,
    required String svgPath, 
    required String title,
    required String description,
    required Color iconColor,
    bool isDanger = false,
    bool isLast = false,
  }) {
    // 🟢 ประกาศเรียกใช้งาน TextTheme จากส่วนกลางใน Method นี้ด้วย
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // 📏 เส้นแนวตั้ง
        if (!isLast)
          Positioned(
            top: 40.h, // ขยับลงมาให้พอดีกับไอคอน
            bottom: 0,
            left: 18.25.w, // จัดให้ตรงกลางไอคอน (44/2 - 1.5/2)
            child: Container(
              width: 1.5.w,
              color: AppColors.border.withOpacity(0.8),
            ),
          ),

        // 📍 เนื้อหาทั้งหมด
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอน
            Container(
              width: 37.w, // ขยายพื้นที่กล่องไอคอนให้ใหญ่ขึ้น
              height: 37.w,
              alignment: Alignment.center, // 🟢 จัด SVG ให้อยู่กึ่งกลางกล่อง
              child: SvgPicture.asset(
                svgPath,
                width: 25.w, // 🟢 กำหนดขนาด SVG
                height: 25.h,
                colorFilter: ColorFilter.mode(
                  isDanger ? AppColors.danger : iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
             SizedBox(
              width: 10.w,
            ), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
            
            // เนื้อหา
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 32.0.h,
                ), // เพิ่มระยะห่างด้านล่างแต่ละสเต็ป
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                     SizedBox(height: 6.h),
                    Text(
                      title,
                      // 🟢 ดึง Style จาก Theme
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: isDanger
                            ? AppColors.danger
                            : AppColors.textHigh,
                      ),
                    ),
                     SizedBox(height: 8.h),
                    Text(
                      description,
                      // 🟢 ดึง Style จาก Theme
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13.7.sp,
                        color: isDanger
                            ? AppColors.danger.withOpacity(0.8)
                            : AppColors.textMedium,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}