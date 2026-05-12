import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

// 🟢 Import Design System
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../cubit/onboarding_cubit.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _ProfileSetupView(),
    );
  }
}

class _ProfileSetupView extends StatefulWidget {
  const _ProfileSetupView();

  @override
  State<_ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<_ProfileSetupView> {
  final _nameController = TextEditingController();
  String? _selectedImagePath;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 ดึง TextTheme จากส่วนกลางมาไว้ในตัวแปร เพื่อให้เรียกใช้ง่ายและสั้นลง
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            context.go('/home');
          } else if (state is OnboardingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    // 🟢 ใช้ TextStyle จากส่วนกลาง 
                    Expanded(
                      child: Text(
                        state.message, 
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.danger,
              )
            );
          }
        },
        child: Stack(
          children: [
            // 🌠 1. Premium Gradient Background & SVG Decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(48),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 70,
                    right: 70,
                    child: Opacity(
                      opacity: 1, 
                      child: SvgPicture.asset(
                        'assets/Illustration/vf.svg',
                        height: 230,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 📜 2. Scrollable Content
            SafeArea(
              bottom: false,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 40 * (1 - value)), 
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 168),

                      // 💳 3. The Premium Floating Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textHigh.withOpacity(0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // --- ภาพโปรไฟล์แบบมีมิติ ---
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.1),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 56,
                                      backgroundColor: AppColors.surface,
                                      backgroundImage: _selectedImagePath != null
                                          ? FileImage(File(_selectedImagePath!))
                                          : null,
                                      child: _selectedImagePath == null
                                          ? Icon(
                                              Icons.person,
                                              size: 48,
                                              color: AppColors.primary.withOpacity(0.4),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
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
                                    child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // 🟢 กล่องใส่ชื่อ (ดึง Style พื้นฐานมาจาก Theme แบบ 100%)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textHigh.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _nameController,
                                // 🟢 ใช้ TextTheme จาก Theme.of(context)
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'กรุณาระบุชื่อของคุณ';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "ชื่อของคุณ",
                                  // ส่วนของ Border และ สีต่างๆ ถูกลบออก เพราะมันไปดึงจาก inputDecorationTheme ใน AppTheme มาใช้เลย!
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // --- ปุ่มบันทึกข้อมูล ---
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<OnboardingCubit>().completeSetup(
                                      _nameController.text, 
                                      _selectedImagePath,
                                    );
                                  }
                                },
                                // 🟢 โค้ดลบ style ออกเกือบหมด เพราะขนาดปุ่ม, ความโค้ง, ฟอนต์ ดึงมาจาก elevatedButtonTheme ใน AppTheme อัตโนมัติ
                                // 🟢 โค้ดเหลือแค่เงาที่เราอยาก Customize พิเศษในหน้านี้
                                style: ElevatedButton.styleFrom(
                                  elevation: 8,
                                  shadowColor: AppColors.primary.withOpacity(0.4),
                                ),
                                // 🟢 Text ลบคำสั่ง style: ทิ้งไปได้เลย! มันรู้อัตโนมัติว่าต้องใช้ฟอนต์ Prompt สีขาว พิมพ์หนา
                                label: const Text("เริ่มใช้งาน"),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              "การกดเริ่มใช้งาน ถือว่าคุณยอมรับ\nข้อตกลงและนโยบายความเป็นส่วนตัวของเรา",
                              textAlign: TextAlign.center,
                              // 🟢 ดึงจาก Theme พร้อมแก้สีให้อ่อนลง
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.textLow,
                                height: 1.5,
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}