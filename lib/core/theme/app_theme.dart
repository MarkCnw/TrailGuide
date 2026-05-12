import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    // 🟢 1. เปลี่ยนฟอนต์ฐานเป็น Prompt
    final baseTextTheme = GoogleFonts.promptTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      
      // 2. กำหนดชุดสีหลัก (Color Palette)
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        error: AppColors.danger,
        surface: AppColors.surface,
      ),
      
      // 3. 📝 Text Theme (ระบบตัวอักษร)
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: AppColors.textHigh, fontWeight: FontWeight.w900, letterSpacing: -1.0),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: AppColors.textHigh, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: AppColors.textHigh),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: AppColors.textMedium),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: AppColors.textMedium, fontWeight: FontWeight.w600),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: AppColors.textLow),
      ),

      // 4. 📱 AppBar Theme (แถบด้านบนสไตล์คลีน)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent, // ป้องกันสีเพี้ยนตอน Scroll
        elevation: 0,
        centerTitle: true, 
        iconTheme: const IconThemeData(color: AppColors.textHigh),
        // 🟢 เปลี่ยนเป็น Prompt
        titleTextStyle: GoogleFonts.prompt(
          color: AppColors.textHigh,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),

      // =========================================================
      // 🎯 BUTTON DESIGN SYSTEM (ระบบปุ่มกดมาตรฐาน)
      // =========================================================

      // 5. 🔘 Primary Button (ElevatedButton) - ปุ่มหลัก
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border, 
          disabledForegroundColor: AppColors.textLow, 
          elevation: 0, 
          minimumSize: const Size(64, 56), 
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
          ),
          // 🟢 เปลี่ยนเป็น Prompt
          textStyle: GoogleFonts.prompt(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // 6. 🔲 Secondary Button (OutlinedButton) - ปุ่มรองขอบใส
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textHigh,
          disabledForegroundColor: AppColors.textLow,
          side: const BorderSide(color: AppColors.border, width: 1.5), 
          minimumSize: const Size(64, 56), 
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // 🟢 เปลี่ยนเป็น Prompt
          textStyle: GoogleFonts.prompt(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // 7. 📝 Tertiary Button (TextButton) - ปุ่มทางเลือก (ไม่มีขอบ/พื้นหลัง)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textMedium, 
          minimumSize: const Size(64, 48), 
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // 🟢 เปลี่ยนเป็น Prompt
          textStyle: GoogleFonts.prompt(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // =========================================================
      // ⌨️ INPUT & FORMS (ระบบฟอร์มกรอกข้อมูล)
      // =========================================================

      // 8. ⌨️ TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background, 
        hintStyle: TextStyle(color: AppColors.textLow.withOpacity(0.8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2), 
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5), 
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      
      // =========================================================
      // 🗂️ SURFACES & POPUPS (ระบบพื้นผิวและการ์ด)
      // =========================================================

      // 9. 💳 Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), 
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // 10. 💬 Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28), 
        ),
        // 🟢 เปลี่ยนเป็น Prompt
        titleTextStyle: GoogleFonts.prompt(
          color: AppColors.textHigh,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        // 🟢 เปลี่ยนเป็น Prompt
        contentTextStyle: GoogleFonts.prompt(
          color: AppColors.textMedium,
          fontSize: 15,
          height: 1.5,
        ),
      ),

      // 11. ⬆️ Bottom Sheet Theme (เมนูเลื่อนจากด้านล่าง)
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)), 
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // 12. 🔔 SnackBar Theme (ป้ายแจ้งเตือนที่ลอยขึ้นมา)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textHigh, 
        // 🟢 เปลี่ยนเป็น Prompt
        contentTextStyle: GoogleFonts.prompt(color: Colors.white, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }
}