import 'package:flutter/material.dart';
import 'package:trail_guide/core/constants/app_colors.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 🟢 ปุ่ม Back กลับหน้าโปรไฟล์
        iconTheme: const IconThemeData(color: AppColors.textHigh),
        title: Text(
          "เครดิตและลิขสิทธิ์",
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textHigh,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          // 🎨 ส่วนที่ 1: ให้เครดิตรูปภาพ SVG ที่โหลดมา
          Text(
            "ภาพประกอบและไอคอน",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textHigh,
              fontSize: 22
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "แอปพลิเคชันนี้ใช้งานภาพประกอบและไอคอนคุณภาพสูงจาก:\n"
            "•Uicons by Flaticon | Free interface icons (Community)\n"
            "•Basil Icons (Community)\n"
            "•Solar Icons Set (Community)\n"
            "•CRISTIAN MUÑOZ 7000 FREE UI ICONS (Community)\n"
            "•5000+ Icon Set (Community)\n"
            "•https://fontawesome.com/ \n"
            "•Illustration by https://www.pixeltrue.com \n",
            
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: AppColors.textMedium,
              height: 1.6,
            ),
          ),
          
          const Divider(color: AppColors.border),
          const SizedBox(height: 32),

          // 🛠️ ส่วนที่ 2: ปุ่มกดไปหน้าลิขสิทธิ์ Open Source ของ Google
          Text(
            "ลิขสิทธิ์ซอฟต์แวร์ (Open Source)",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textHigh,
              fontSize: 22
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "เครื่องมือและชุดคำสั่ง (Libraries) ที่ใช้ในการพัฒนาแอปพลิเคชันนี้",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
              fontSize: 16
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'TrailGuide',
              applicationVersion: '1.0.0',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textHigh,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.description_rounded),
            label: const Text("ดูลิขสิทธิ์ซอฟต์แวร์ทั้งหมด"),
          ),
        ],
      ),
    );
  }
}