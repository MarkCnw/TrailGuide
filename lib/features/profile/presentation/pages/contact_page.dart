import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:trail_guide/core/constants/app_colors.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
          "ติดต่อเรา",
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Symbols.mail, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  "ฝ่ายสนับสนุน TrailGuide",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "หากพบปัญหาการใช้งานหรือมีข้อเสนอแนะ ติดต่อเราได้ที่:",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "support.trailguide@email.com",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
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