import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 🟢 ดึง ScreenUtil มาใช้
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

// 🟢 Import Design System
import '../../../../core/constants/app_colors.dart';
import '../cubit/onboarding_cubit.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileSetupView();
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

  // 🟢 เพิ่มสถานะการยอมรับข้อตกลง (บังคับติ๊กถึงจะไปต่อได้)
  bool _isAccepted = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  // 📜 ฟังก์ชันแสดงหน้าต่าง (Dialog) ข้อตกลงฉบับเต็มเพื่อกันโดนฟ้อง
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r), // 🟢 ใช้ .r
          ),
          title: Text(
            "ข้อกำหนดและเงื่อนไข",
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              "โปรดอ่านข้อตกลงนี้อย่างละเอียดก่อนใช้งานแอปพลิเคชัน TrailGuide การกดปุ่มยอมรับหรือเข้าใช้งานแอปพลิเคชัน ถือว่าคุณเข้าใจและยอมรับเงื่อนไขทั้งหมดดังต่อไปนี้:\n\n"
              "1. ไม่ใช่อุปกรณ์ช่วยชีวิต (Not a Life-Saving Device)\n"
              "แอปพลิเคชันนี้ถูกออกแบบมาเพื่อเป็นเครื่องมืออำนวยความสะดวกเบื้องต้นในการทำกิจกรรมกลางแจ้งเท่านั้น ไม่ใช่อุปกรณ์ช่วยชีวิต อุปกรณ์นำทางระดับมืออาชีพ หรืออุปกรณ์ขอความช่วยเหลือฉุกเฉิน (SOS) ผู้ใช้ไม่ควรพึ่งพาแอปพลิเคชันนี้เพียงอย่างเดียวในสถานการณ์ฉุกเฉิน หรือในสภาพแวดล้อมที่เสี่ยงอันตราย\n\n"
              "2. การให้บริการ \"ตามสภาพ\" และข้อจำกัดทางเทคโนโลยี (As-Is)\n"
              "ระบบเข็มทิศ, พิกัด GPS, และการเชื่อมต่อเครือข่ายระหว่างเครื่อง (Peer-to-Peer) ภายในแอปพลิเคชัน ทำงานภายใต้ข้อจำกัดของฮาร์ดแวร์โทรศัพท์มือถือและสภาพแวดล้อม ผู้พัฒนาให้บริการแอปพลิเคชันนี้ \"ตามสภาพที่มี\" และไม่รับประกันความถูกต้อง ความแม่นยำ หรือความเสถียรของการเชื่อมต่อในทุกสถานการณ์\n\n"
              "3. การยอมรับความเสี่ยง (Assumption of Risk)\n"
              "การเดินป่าและกิจกรรมกลางแจ้งมีความเสี่ยงโดยธรรมชาติ ผู้ใช้ตระหนักและยอมรับความเสี่ยงที่อาจเกิดขึ้นด้วยตนเอง\n\n"
              "4. การจำกัดความรับผิด (Limitation of Liability)\n"
              "ไม่ว่าในกรณีใดๆ ก็ตาม ผู้พัฒนาซอฟต์แวร์จะไม่รับผิดชอบต่อความสูญเสีย ความเสียหาย การบาดเจ็บ การเสียชีวิต การสูญหายของทรัพย์สิน หรือการหลงทาง ที่เป็นผลมาจากการใช้งาน การตัดสินใจ หรือความผิดพลาดที่เกิดขึ้นจากข้อมูลในแอปพลิเคชัน TrailGuide",
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textMedium,
                height: 1.6, // 🟢 ไม่ต้องใส่ .h
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "ปิดและรับทราบ",
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            context.go('/home');
          } else if (state is OnboardingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w), // 🟢 ใช้ .w
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
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        // 🟢 ครอบ GestureDetector เพื่อให้แตะจอแล้วคีย์บอร์ดหุบ (UX ที่ดี)
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w, // 🟢 ใช้ .w
                        vertical: 24.h,   // 🟢 ใช้ .h
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🌟 1. ส่วนหัว: โลโก้พร้อมชื่อแอปสไตล์ Hi-end
                          SizedBox(height: 20.h), // 🟢 ใช้ .h
                          Column(
                            children: [
                              SvgPicture.asset(
                                'assets/logo/Vector.svg',
                                height: 50.w, // 🟢 ใช้ .w เพื่อคุมให้เป็นสี่เหลี่ยมจัตุรัส
                                width: 50.w,
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),

                          SizedBox(height: 48.h),

                          // 📝 2. ข้อความต้อนรับ
                          Text(
                            "สร้างโปรไฟล์ของคุณ",
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textHigh,
                              letterSpacing: -0.5,
                              fontSize: 26.sp, // 🟢 ใช้ .sp
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "เพิ่มรูปภาพและชื่อเพื่อให้เพื่อนในทีมจำคุณได้",
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMedium,
                              height: 1.5,
                              fontSize: 14.sp,
                            ),
                          ),

                          SizedBox(height: 56.h),

                          // 📸 3. ส่วนอัปโหลดรูปภาพ
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 130.w, // 🟢 ใช้ .w
                                  height: 130.w, 
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border.withOpacity(0.3),
                                      width: 1.w, // 🟢 ใช้ .w
                                    ),
                                    image: _selectedImagePath != null
                                        ? DecorationImage(
                                            image: FileImage(
                                              File(_selectedImagePath!),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _selectedImagePath == null
                                      ? Icon(
                                          Icons.person_rounded,
                                          size: 56.sp, // 🟢 ใช้ .sp
                                          color: AppColors.textLow.withOpacity(0.4),
                                        )
                                      : null,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.w), // 🟢 ใช้ .w
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface,
                                      width: 4.w,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20.sp, // 🟢 ใช้ .sp
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 48.h),

                          // 🟢 4. กล่องใส่ชื่อ
                          TextFormField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHigh,
                              fontSize: 24.sp, // 🟢 ใช้ .sp
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณาระบุชื่อของคุณ';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "พิมพ์ชื่อของคุณ...",
                              hintStyle: textTheme.titleLarge?.copyWith(
                                color: AppColors.textLow.withOpacity(0.5),
                                fontSize: 24.sp,
                              ),
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.h, // 🟢 ใช้ .h
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.border.withOpacity(0.5),
                                  width: 1.5.w,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                  width: 2.w,
                                ),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.danger,
                                  width: 1.5.w,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),
                          SizedBox(height: 32.h),

                          // 🛡️ 5. เงื่อนไขการใช้งาน (Checkbox)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24.w, // 🟢 ใช้ .w
                                height: 24.w, // ใช้ .w ให้เป็นจัตุรัส
                                child: Checkbox(
                                  value: _isAccepted,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r), // 🟢 ใช้ .r
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _isAccepted = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showTermsDialog,
                                  child: Text.rich(
                                    TextSpan(
                                      text:
                                          "ฉันได้อ่านและยอมรับว่าแอปนี้ไม่ใช่อุปกรณ์ช่วยชีวิต และผู้พัฒนาจะไม่รับผิดชอบต่อความเสียหายใดๆ ",
                                      style: textTheme.labelSmall?.copyWith(
                                        color: AppColors.textMedium,
                                        height: 1.5, // 🟢 เอา .h ออก ป้องกันบัคบรรทัดห่าง
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "อ่านข้อตกลงฉบับเต็ม",
                                          style: textTheme.labelSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          // 🚀 6. ปุ่มเริ่มต้นใช้งาน
                          SizedBox(
                            width: double.infinity,
                            height: 58.h, // 🟢 ใช้ .h
                            child: ElevatedButton(
                              onPressed: _isAccepted
                                  ? () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<OnboardingCubit>()
                                            .completeSetup(
                                              _nameController.text,
                                              _selectedImagePath,
                                            );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.border, 
                                disabledForegroundColor: AppColors.textLow,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r), // 🟢 ใช้ .r
                                ),
                              ),
                              child: Text(
                                "เริ่มใช้งาน",
                                style: TextStyle(
                                  fontSize: 16.sp, // 🟢 ใช้ .sp
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}