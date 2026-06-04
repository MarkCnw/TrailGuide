import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:svg_flutter/svg.dart';
import 'package:trail_guide/core/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHigh),
        title: Text(
          "เกี่ยวกับเรา",
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textHigh,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          _buildAppHeader(textTheme),
          const SizedBox(height: 32),
          _buildMissionStatement(textTheme),
          const SizedBox(height: 40),
          _buildFeaturesSection(context, textTheme),
          const SizedBox(height: 48),
          _buildDeveloperCredit(textTheme),
        ],
      ),
    );
  }

  // 🌟 1. ส่วนหัว (App Identity) - ดีไซน์ไร้ขอบ เน้นเงาบางๆ
  Widget _buildAppHeader(TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
        
          child: SvgPicture.asset('assets/logo/Vector.svg',width: 70,height: 70,)
        ),
        const SizedBox(height: 24),
        Text(
          "TrailGuide",
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textHigh,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "เวอร์ชัน 1.0.0",
          style: textTheme.titleSmall?.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 🎯 2. ส่วนพันธกิจ (Mission Statement) - คลีนๆ อ่านง่าย
  Widget _buildMissionStatement(TextTheme textTheme) {
    return Text(
      "ยกระดับความปลอดภัยให้กับการเดินป่าและการทำกิจกรรมกลางแจ้ง เพื่อให้นักเดินทางเชื่อมต่อและดูแลเพื่อนร่วมทีมได้เสมอ แม้ในพื้นที่ที่ไร้สัญญาณอินเทอร์เน็ต",
      textAlign: TextAlign.center,
      style: textTheme.bodyLarge?.copyWith(
        color: AppColors.textMedium,
        height: 1.6,
      ),
    );
  }

  // ✨ 3. ส่วนฟีเจอร์เด่น - จัดกลุ่มรวมกันในการ์ดเดียว (iOS Settings Style)
  Widget _buildFeaturesSection(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            "ฟีเจอร์เด่น",
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildFeatureRow(
                context,
                icon: Symbols.radar,
                title: "ออฟไลน์เรดาร์ (P2P)",
                desc: "ค้นหาพิกัดเพื่อนร่วมทีมโดยไม่ต้องใช้เน็ต",
                isTop: true,
              ),
              const Divider(color: AppColors.border, height: 1, indent: 64),
              _buildFeatureRow(
                context,
                icon: Symbols.emergency,
                title: "ระบบแจ้งเตือนฉุกเฉิน",
                desc: "ส่งพิกัด SOS ทันทีเมื่อเกิดเหตุไม่คาดฝัน",
                iconColor: AppColors.danger,
              ),
              const Divider(color: AppColors.border, height: 1, indent: 64),
              _buildFeatureRow(
                context,
                icon: Symbols.history,
                title: "บันทึกประวัติการเดินทาง",
                desc: "สรุประยะทางและเวลาที่ใช้ในแต่ละทริป",
                isBottom: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🧑‍💻 4. ส่วนเครดิตนักพัฒนา - มินิมอล โชว์ชื่อชัดเจน
  Widget _buildDeveloperCredit(TextTheme textTheme) {
    return Column(
      children: [
        Text(
          "พัฒนาและออกแบบโดย",
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Chinnawong Moonkhonburi",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textHigh,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 🧩 ส่วนประกอบย่อย (Sub-widgets)
  // ==========================================

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    Color iconColor = AppColors.primary,
    bool isTop = false,
    bool isBottom = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: isTop ? 20 : 16,
        bottom: isBottom ? 20 : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}