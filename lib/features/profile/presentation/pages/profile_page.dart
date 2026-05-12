import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
// 🟢 เอา import 'package:google_fonts/google_fonts.dart'; ออกไปแล้ว ดึงจาก Theme แทน

// Import ของในโปรเจกต์
import '../../../../core/constants/app_colors.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 ใช้ .value เพื่อดึง Cubit ตัวเดียวกันกับที่ main.dart provide ไว้
    // (ไม่สร้าง BlocProvider ใหม่ทับ เพื่อให้ HomePage เห็นข้อมูลอัปเดตด้วย)
    final cubit = context.read<OnboardingCubit>()..loadUserProfile();
    return BlocProvider.value(
      value: cubit,
      child: const _ProfileView(),
    );
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
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textHigh)),
        content: Text(content, style: textTheme.bodyMedium?.copyWith(color: AppColors.textMedium, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ตกลง", style: textTheme.labelLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
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
                                    style: textTheme.headlineSmall?.copyWith(
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
                              Row(
                                children: [
                                  _buildMiniStat(
                                    context: context, // 🟢 ส่ง Context
                                    title: "ทริป",
                                    value: "0",
                                    icon: Icons.map_rounded,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: AppColors.border,
                                  ), // เส้นคั่นกลาง
                                  _buildMiniStat(
                                    context: context, // 🟢 ส่ง Context
                                    title: "ระยะทาง",
                                    value: "0 km",
                                    icon: Icons.directions_walk_rounded,
                                  ),
                                ],
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
                                    borderRadius: BorderRadius.circular(16),
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
                            color: AppColors.textMedium,
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
                              icon: Icons.privacy_tip_rounded,
                              title: "Privacy Policy",
                              iconColor: AppColors.info,
                              isTop: true,
                              onTap: () => _showInfoDialog(
                                "Privacy Policy", 
                                "แอปพลิเคชันนี้มีการเก็บข้อมูลรูปโปรไฟล์, ชื่อ และตำแหน่ง (GPS) ของคุณเพื่อใช้ในการแสดงผลบนเรดาร์ ข้อมูลถูกประมวลผลผ่านระบบออฟไลน์ P2P และไม่มีการเก็บไว้ในเซิร์ฟเวอร์สาธารณะ"
                              ),
                            ),
                            const Divider(
                              color: AppColors.border,
                              height: 1.5,
                              indent: 64,
                            ),
                            _MenuTile(
                              icon: Icons.email_rounded,
                              title: "Contact Email",
                              iconColor: AppColors.warning,
                              onTap: () => _showInfoDialog(
                                "Contact Email", 
                                "หากพบปัญหาการใช้งานหรือมีข้อเสนอแนะ ติดต่อเราได้ที่:\n\nsupport.trailguide@email.com"
                              ),
                            ),
                            const Divider(
                              color: AppColors.border,
                              height: 1.5,
                              indent: 64,
                            ),
                            _MenuTile(
                              icon: Icons.info_rounded,
                              title: "About Us",
                              iconColor: AppColors.textMedium,
                              isBottom: true,
                              onTap: () => _showInfoDialog(
                                "About Us", 
                                "TrailGuide เวอร์ชัน 1.0.0\n\nแอปพลิเคชันเรดาร์ออฟไลน์สำหรับนักเดินป่า ช่วยให้คุณไม่หลงทางและเชื่อมต่อกับเพื่อนร่วมทีมได้ตลอดเวลาแม้ไม่มีสัญญาณอินเทอร์เน็ต"
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🚪 ปุ่ม Logout
                      TextButton.icon(
                        onPressed: () {}, // TODO: Logout logic
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.danger,
                        ),
                        label: Text(
                          "ออกจากระบบ",
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
  final IconData icon; // 🟢 โค้ดเดิมที่คุณส่งมายังเป็นแบบ Icon ปกติ ซึ่งใช้งานได้ตามปกติครับ
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
              
              child: Icon(icon, color: iconColor, size: 22),
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