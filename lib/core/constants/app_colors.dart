import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // ป้องกันการสร้าง Instance (ไม่ให้เรียก new AppColors())

  // 🌲 Brand / Primary (เขียวป่าลึก - ดูพรีเมียมและน่าเชื่อถือ)
  static const Color primary = Color(0xFF235347);
  static const Color primaryLight = Color(0xFF3A7D6D);
  static const Color primaryDark = Color(0xFF16362E);

  // 🍃 Surface & Background (สีพื้นผิว)
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (เทาอ่อนสุดๆ สบายตา)
  static const Color surface = Colors.white; // ขาวสะอาด สำหรับการ์ด
  static const Color border = Color(0xFFE2E8F0); // Slate 200 (ขอบจางๆ)

  // 🖋️ Text & Typography (สีตัวอักษร)
  static const Color textHigh = Color(0xFF0F172A); // Slate 900 (หัวข้อเด่นๆ)
  static const Color textMedium = Color(0xFF475569); // Slate 600 (ข้อความทั่วไป)
  static const Color textLow = Color(0xFF94A3B8); // Slate 400 (คำอธิบายรอง/Hint)

  // 🚨 Status & Alerts (สีสถานะ)
  static const Color danger = Color(0xFFEF4444); // Red 500 (ปุ่ม SOS / แจ้งเตือนอันตราย)
  static const Color warning = Color(0xFFF59E0B); // Amber 500 (สถานะ Host / ระยะห่าง)
  static const Color success = Color(0xFF10B981); // Emerald 500 (เชื่อมต่อสำเร็จ)
  static const Color info = Color(0xFF3B82F6); // Blue 500 (พิกัด GPS / เข็มทิศ)
}