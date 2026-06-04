import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:trail_guide/features/history/presentation/cubit/history_cubit.dart';
import 'package:trail_guide/features/history/presentation/cubit/history_state.dart';
import 'package:trail_guide/features/profile/presentation/pages/about_page.dart';
import 'package:trail_guide/features/profile/presentation/pages/contact_page.dart';
import 'package:trail_guide/features/profile/presentation/pages/credits_page.dart';
import 'package:trail_guide/features/profile/presentation/pages/privacy_page.dart';
// 🟢 เอา import 'package:google_fonts/google_fonts.dart'; ออกไปแล้ว ดึงจาก Theme แทน

// Import ของในโปรเจกต์
import '../../../../core/constants/app_colors.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 ลบ BlocProvider ออกทั้งหมด เพราะเรามี OnboardingCubit อยู่ที่ main.dart แล้ว
    return const _ProfileView();
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  String? _imagePath;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // 🟢 1. สั่งให้ดึงข้อมูลโปรไฟล์จาก Local Storage (ผ่าน Cubit ตัวหลักของแอป)
    context.read<OnboardingCubit>().loadUserProfile();
    context.read<HistoryCubit>().getAllTrips();

    // 🟢 2. รอให้ Widget วาดเสร็จ 1 เฟรม แล้วค่อยดึง State มายัดใส่กล่องข้อความ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OnboardingCubit>().state;
      if (state is OnboardingLoaded) {
        _nameController.text = state.profile.nickname;
        if (mounted) setState(() => _imagePath = state.profile.imagePath);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<OnboardingCubit>().completeSetup(
        _nameController.text,
        _imagePath,
      );

      final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'บันทึกข้อมูลสำเร็จ',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
      _toggleEditMode();
    }
  }

  // 🟢 1. เพิ่มฟังก์ชันสำหรับโชว์ข้อความ (ใช้กับ Privacy, Contact, About)
  void _showInfoDialog(String title, String content) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textHigh,
          ),
        ),
        content: Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textMedium,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "ตกลง",
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
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

    // 💡 ทริค UX: ใช้ extendBodyBehindAppBar เพื่อให้พื้นหลังเขียวอมไปถึงขอบจอบนสุด
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "โปรไฟล์ของฉัน",
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingLoaded && !_isEditing) {
            _nameController.text = state.profile.nickname;
            setState(() {
              _imagePath = state.profile.imagePath;
            });
          }
        },
        builder: (context, state) {
          if (state is OnboardingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // 🟩 1. Background โค้งสีเขียว (Hero Background)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.38,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                ),
              ),

              // 📜 2. Scrollable Content
              SafeArea(
                bottom: false,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 💳 2.1 The ID Card (การ์ดผู้ใช้งานลอยทับสีเขียว)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // --- ส่วนรูปโปรไฟล์ ---
                            _ProfileImageSelector(
                              imagePath: _imagePath,
                              isEditing: _isEditing,
                              onTap: _pickImage,
                            ),
                            const SizedBox(height: 20),

                            // --- ส่วนชื่อและตำแหน่ง ---
                            if (_isEditing)
                              TextFormField(
                                controller: _nameController,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHigh,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'กรุณาระบุชื่อ' : null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.background,
                                  hintText: "ชื่อเรียกของคุณ",
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  Text(
                                    _nameController.text.isEmpty
                                        ? "ผู้ใช้งานใหม่"
                                        : _nameController.text,
                                    style: textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textHigh,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 16),

                                  const Divider(
                                    color: AppColors.border,
                                    thickness: 1,
                                    height: 20,
                                  ),
                                ],
                              ),

                            const SizedBox(height: 20),

                            // --- ส่วนสถิติ 2 คอลัมน์ (แสดงเฉพาะตอนไม่ได้ Edit เพื่อความคลีน) ---
                            if (!_isEditing) ...[
                              BlocBuilder<HistoryCubit, HistoryState>(
                                builder: (context, state) {
                                  // 1. 🏁 ตั้งค่าเริ่มต้นเตรียมไว้ก่อน
                                  int totalTrips = 0;
                                  double totalDistance = 0.0;

                                  // 2. 🐷 ทุบกระปุก! ถ้าโหลดข้อมูลสำเร็จ ให้เอาลูป for-in มาวิ่งบวกเลขตรงนี้
                                  if (state is HistoryLoaded) {
                                    final trips = state.trips;
                                    // 1. 🔢 หาจำนวนทริปทั้งหมด
                                    totalTrips = trips.length;
                                    // 2. 🛣️ หาระยะทางรวม (ใช้ลูป for-in เหมือนหยอดกระปุก)
                                    totalDistance = 0.0;
                                    for (var trip in trips) {
                                      // ดึงค่าระยะทางของแต่ละทริปมาบวกสะสม
                                      double distance = trip.totalDistance;
                                      if (!distance.isNaN &&
                                          !distance.isInfinite) {
                                        totalDistance += distance;
                                      }
                                    }
                                  }

                                  String distanceValue;
                                  String distanceUnit;

                                  if (totalDistance < 1000) {
                                    distanceValue = totalDistance
                                        .toStringAsFixed(0);
                                    distanceUnit = "เมตร";
                                  } else {
                                    distanceValue = (totalDistance / 1000)
                                        .toStringAsFixed(2);
                                    distanceUnit = "กม.";
                                  }

                                  // 3. 🧮 นำค่าระยะทาง (เมตร) มาจัดรูปแบบเตรียมแสดงผล

                                  // 4. 🎨 คืนค่า (return) หน้าตา UI ออกไป
                                  return Row(
                                    children: [
                                      _buildMiniStat(
                                        context: context,
                                        title: "ทริป",
                                        value: totalTrips
                                            .toString(), // 🟢 นำตัวแปรมาเสียบแทน "0"
                                        icon: Icons.map_rounded,
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: AppColors.border,
                                      ),
                                      _buildMiniStat(
                                        context: context,
                                        title: "ระยะทาง",
                                        value:
                                            "$distanceValue $distanceUnit", // 🟢 ตัวแปรสองตัวต่อกันด้วยช่องว่าง
                                        icon:
                                            Icons.directions_walk_rounded,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],

                            // --- ปุ่ม Action ภายใน Card (Contextual Button) ---
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _isEditing
                                    ? _saveProfile
                                    : _toggleEditMode,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isEditing
                                      ? AppColors.success
                                      : AppColors.background,
                                  foregroundColor: _isEditing
                                      ? Colors.white
                                      : AppColors.textHigh,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                icon: Icon(
                                  _isEditing
                                      ? Icons.check_circle_rounded
                                      : Icons.edit_rounded,
                                  size: 20,
                                ),
                                label: Text(
                                  _isEditing
                                      ? "บันทึกโปรไฟล์"
                                      : "แก้ไขข้อมูล",
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ⚙️ 2.2 Settings Section (ดีไซน์แบบ Grouped List สไตล์ iOS)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          bottom: 12,
                        ),
                        child: Text(
                          "การตั้งค่าระบบ",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textHigh,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            _MenuTile(
                              icon: Symbols.shield_lock,
                              title: "ความเป็นส่วนตัวเเละความปลอดภัย",
                              iconColor: AppColors.textHigh,
                              isTop: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPage(),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.border,
                              height: 1.5,
                              indent: 64,
                            ),
                            _MenuTile(
                              icon: Symbols.mail,
                              title: "ติดต่อเรา",
                              iconColor: AppColors.textHigh,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactPage(),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.border,
                              height: 1.5,
                              indent: 64,
                            ),
                            _MenuTile(
                              icon: Symbols.info,
                              title: "เกี่ยวกับเรา",
                              iconColor: AppColors.textHigh,
                              // 🔴 ลบ isBottom: true ออกจากตรงนี้แล้ว
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AboutPage(),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              color: AppColors.border,
                              height: 1.5,
                              indent: 64,
                            ),
                            _MenuTile(
                              icon: Symbols.copyright_sharp,
                              title: "เครดิตและลิขสิทธิ์",
                              iconColor: AppColors.textHigh,
                              isBottom:
                                  true, // 🟢 เก็บไว้แค่อันสุดท้ายอันเดียว
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreditsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget สถิติเล็กๆ ในการ์ด
  Widget _buildMiniStat({
    required BuildContext context, // 🟢 ส่ง Context มารับ Theme
    required String title,
    required String value,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textLow, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textHigh,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧩 Extracted Widgets
// -----------------------------------------------------------------------------

class _ProfileImageSelector extends StatelessWidget {
  final String? imagePath;
  final bool isEditing;
  final VoidCallback onTap;

  const _ProfileImageSelector({
    required this.imagePath,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // 🟩 รูปภาพ
          Container(
            padding: const EdgeInsets.all(6), // ขอบสีขาวรอบรูป
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: CircleAvatar(
              key: ValueKey(imagePath),
              radius: 54,
              backgroundColor: AppColors.surface,
              backgroundImage: imagePath != null
                  ? FileImage(File(imagePath!))
                  : null,
              child: imagePath == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: AppColors.textLow.withOpacity(0.5),
                    )
                  : null,
            ),
          ),

          // 📷 ไอคอนกล้องตอนแก้ไข
          if (isEditing)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData
  icon; // 🟢 โค้ดเดิมที่คุณส่งมายังเป็นแบบ Icon ปกติ ซึ่งใช้งานได้ตามปกติครับ
  final String title;
  final Color iconColor;
  final bool isTop;
  final bool isBottom;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.isTop = false,
    this.isBottom = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // 🟢 ดึง Theme

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isTop ? 24 : 0),
        bottom: Radius.circular(isBottom ? 24 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              child: Icon(icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.border,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
