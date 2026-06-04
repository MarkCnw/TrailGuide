import 'package:flutter/material.dart';
import 'package:trail_guide/core/constants/app_colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  Widget _buildSection(TextTheme textTheme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textHigh,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

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
          "นโยบายความเป็นส่วนตัว",
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
          Text(
            "แอปพลิเคชัน TrailGuide ให้ความสำคัญสูงสุดกับความเป็นส่วนตัวและความปลอดภัยของข้อมูลผู้ใช้งาน นโยบายฉบับนี้อธิบายถึงวิธีการที่เราจัดการกับข้อมูลของคุณ",
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMedium,
              height: 1.6,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          _buildSection(
            textTheme,
            "1. ข้อมูลที่เราเข้าถึงและจัดเก็บ",
            "• ข้อมูลตำแหน่งที่ตั้ง (GPS): เราขอสิทธิ์เข้าถึงพิกัดละติจูดและลองจิจูดของคุณขณะใช้งานแอปพลิเคชัน\n"
            "• ข้อมูลโปรไฟล์: ชื่อเรียก (Nickname) และรูปภาพโปรไฟล์ที่คุณเลือก\n"
            "• ข้อมูลเซนเซอร์: การอ่านค่าจากเข็มทิศ (Compass) และความเร็วในการเคลื่อนที่",
          ),

          _buildSection(
            textTheme,
            "2. วัตถุประสงค์ในการใช้งานข้อมูล",
            "ข้อมูลที่กล่าวมาข้างต้นถูกนำมาใช้เพื่อฟังก์ชันการทำงานหลักของแอปพลิเคชันเท่านั้น ได้แก่ การแสดงตำแหน่งของคุณและเพื่อนบนหน้าจอเรดาร์, การคำนวณระยะทางสะสมในประวัติการเดินทาง, และการส่งสัญญาณขอความช่วยเหลือ (SOS) ในกรณีฉุกเฉิน",
          ),

          _buildSection(
            textTheme,
            "3. การประมวลผลแบบออฟไลน์ (Offline-First)",
            "แอปพลิเคชันนี้ทำงานผ่านระบบเครือข่ายแบบ Peer-to-Peer (P2P) ข้อมูลตำแหน่งและโปรไฟล์ของคุณจะถูกส่งต่อระหว่างอุปกรณ์ภายในกลุ่มของคุณโดยตรงเท่านั้น ไม่มีการอัปโหลด บันทึก หรือส่งผ่านข้อมูลใดๆ ไปยังเซิร์ฟเวอร์คลาวด์ (Cloud Server) หรือระบบส่วนกลาง",
          ),

          _buildSection(
            textTheme,
            "4. การจัดเก็บข้อมูลภายในอุปกรณ์ (Local Storage)",
            "ข้อมูลประวัติการเดินทาง สถิติ และรูปโปรไฟล์ของคุณ จะถูกบันทึกและเข้ารหัสลงในฐานข้อมูลภายในอุปกรณ์ของคุณเอง (Local Database) หากคุณลบแอปพลิเคชัน ข้อมูลเหล่านี้จะถูกลบออกจากเครื่องอย่างถาวรโดยไม่สามารถกู้คืนได้",
          ),

          _buildSection(
            textTheme,
            "5. การแชร์ข้อมูลให้บุคคลที่สาม",
            "เราขอรับรองว่า เราไม่มีนโยบายในการขาย แลกเปลี่ยน หรือส่งต่อข้อมูลพิกัดตำแหน่งและข้อมูลส่วนบุคคลของคุณ ให้กับบริษัทโฆษณา หน่วยงานภายนอก หรือบุคคลที่สามในทุกกรณี",
          ),

          _buildSection(
            textTheme,
            "6. สิทธิและการควบคุมของคุณ",
            "คุณมีสิทธิเด็ดขาดในการควบคุมข้อมูลของตนเอง คุณสามารถเข้าไปที่การตั้งค่าของสมาร์ทโฟนเพื่อเพิกถอนสิทธิ์ (Revoke) การเข้าถึง GPS, รูปภาพ และเครือข่ายระดับท้องถิ่น (Local Network) ได้ตลอดเวลา",
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),

          Center(
            child: Text(
              "อัปเดตล่าสุด: พฤษภาคม 2026",
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textLow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}