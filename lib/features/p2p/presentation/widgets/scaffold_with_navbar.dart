import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key, // 🟢 ปรับให้สั้นลงตามมาตรฐานสมัยใหม่
  });

  @override
  Widget build(BuildContext context) {
    // ดึงค่า Index ปัจจุบันเพื่อเช็คว่า Tab ไหนถูกเลือกอยู่
    final int currentIndex = navigationShell.currentIndex;
    
    // 🟢 ดึง TextTheme จากส่วนกลางมาใช้เฉพาะฟอนต์
    final textTheme = Theme.of(context).textTheme;

    // กำหนดสีธีม (TrailGuide Theme) ตามที่คุณกำหนดไว้
    const Color activeColor = Color(0xFF2E7D32); // สีเขียว Forest Green
    const Color inactiveColor = Colors.grey;

    return Scaffold(
      // ส่วนเนื้อหาหน้าจอ (จะเปลี่ยนไปตาม Tab ที่เลือก)
      body: navigationShell,

      // ส่วนแถบเมนูด้านล่าง
      bottomNavigationBar: NavigationBarTheme(
        // ✨ เคล็ดลับ: ใช้ Theme Data ครอบเพื่อลบ Effect แสงวูบวาบ (Splash/Ripple)
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent, // ลบวงรีสีๆ พื้นหลังไอคอน
          overlayColor: WidgetStateProperty.all(Colors.transparent), // ลบแสงวูบวาบตอนกด
          
          // 🟢 เปลี่ยนมาดึงฟอนต์จาก Theme แต่กำหนดสีเอง
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelSmall?.copyWith(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600, 
                  color: activeColor // 🔴 สีเดิมตามความต้องการ
              );
            }
            return textTheme.labelSmall?.copyWith(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: inactiveColor // 🔴 สีเดิมตามความต้องการ
            );
          }),
        ),
        
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (int index) {
            navigationShell.goBranch(
              index,
              // ให้กลับไปหน้าแรกของ Tab นั้นๆ ถ้ากดซ้ำ
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          
          backgroundColor: Colors.white,
          elevation: 0, // แบบแบนราบ (Flat)
          height: 65, // ความสูงกำลังดี
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

          destinations: [
            // 1. 🏠 Home Tab
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icons/navigation/Home Angle 2.svg',
                width: 26,
                colorFilter: ColorFilter.mode(
                  currentIndex == 0 ? activeColor : inactiveColor, BlendMode.srcIn),
              ),
              selectedIcon: SvgPicture.asset(
                'assets/icons/navigation/Homee.svg',
                width: 26,
                colorFilter: const ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
              label: 'หน้าหลัก',
            ),

            // 2. 📡 Radar Tab
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icons/navigation/Round Graph.svg', 
                width: 28,
                colorFilter: ColorFilter.mode(
                  currentIndex == 1 ? activeColor : inactiveColor, BlendMode.srcIn),
              ),
              selectedIcon: SvgPicture.asset(
                'assets/icons/navigation/radar.svg',
                width: 28,
                colorFilter: const ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
              label: 'เรดาร์',
            ),

            // 3. 📜 History Tab
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icons/navigation/pending.svg',
                width: 23,
                colorFilter: ColorFilter.mode(
                  currentIndex == 2 ? activeColor : inactiveColor, BlendMode.srcIn),
              ),
              selectedIcon: SvgPicture.asset(
                'assets/icons/navigation/clock-nine.svg',
                width: 23,
                colorFilter: const ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
              label: 'ประวัติ',
            ),

            // 4. 👤 Profile Tab
            NavigationDestination(
              icon: SvgPicture.asset(
                'assets/icons/navigation/user-regular.svg',
                width: 20,
                colorFilter: ColorFilter.mode(
                  currentIndex == 3 ? activeColor : inactiveColor, BlendMode.srcIn),
              ),
              selectedIcon: SvgPicture.asset(
                'assets/icons/navigation/user-solid.svg',
                width: 20,
                colorFilter: const ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
              label: 'โปรไฟล์',
            ),
          ],
        ),
      ),
    );
  }
}