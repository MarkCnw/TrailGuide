<p align="center">
  <img src="https://github.com/user-attachments/assets/placeholder-trailguide-logo" alt="TrailGuide Logo" width="160">
</p>

<h1 align="center">
  TrailGuide
</h1>

<p align="center">
  <strong>แอปพลิเคชัน Flutter สำหรับสายเดินป่า ช่วยระบุตำแหน่งและสื่อสารผ่านระบบ P2P แบบออฟไลน์</strong>
</p>

<p align="center">
  ออกแบบภายใต้แนวคิด <strong>Offline-First</strong> โดยประมวลผลและเชื่อมต่อแบบ <strong>Peer-to-Peer (P2P)</strong> ระหว่างอุปกรณ์โดยตรง ไม่ต้องพึ่งพาสัญญาณอินเทอร์เน็ตหรือเซิร์ฟเวอร์ส่วนกลาง เหมาะสำหรับการใช้งานในพื้นที่ป่าลึก
</p>

<p align="center">

![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-4CAF50)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue)
![Isar](https://img.shields.io/badge/Database-Isar-orange)

</p>

---

# 📖 ภาพรวมโปรเจกต์

TrailGuide เป็นแอปพลิเคชันบนมือถือที่พัฒนาด้วย **Flutter** เพื่อแก้ปัญหาการพลัดหลงในป่า หรือการขาดการติดต่อสื่อสารเมื่ออยู่ในพื้นที่อับสัญญาณ 

ระบบใช้เทคโนโลยี **Nearby Connections API (Native Android)** เชื่อมต่อผ่านบลูทูธและ Wi-Fi Direct เพื่อสร้างห้อง (Room) และแชร์พิกัด GPS, ทิศทางเข็มทิศ และข้อมูลต่างๆ ระหว่างเพื่อนร่วมทริป โดยข้อมูลทั้งหมดจะถูกซิงค์แบบ Real-time และแสดงผลบนหน้าจอเรดาร์ 

นอกจากนี้ยังมีการจัดเก็บประวัติการเดินทาง (Trip History) ลงในฐานข้อมูล **Isar** ภายในตัวเครื่องแบบ 100% ทำให้มั่นใจได้ว่าข้อมูลพิกัดและการเดินทางของคุณจะถูกเก็บรักษาไว้อย่างปลอดภัยและเป็นส่วนตัว

---

# ✨ ความสามารถหลัก

- 📡 สื่อสารและแชร์พิกัดแบบออฟไลน์ 100% ผ่านระบบ Peer-to-Peer
- 🧭 หน้าจอเรดาร์ติดตามเพื่อนร่วมทริป พร้อมระบบลดความแกว่งของเข็มทิศ (Low-pass filter)
- 🚨 ระบบประกาศเหตุฉุกเฉิน (SOS Broadcast) พร้อมแจ้งเตือนแบบสั่น
- ⚠️ แจ้งเตือนความปลอดภัยทันทีเมื่อเพื่อนร่วมทริปอยู่ห่างเกิน 80 เมตร
- 🗺️ บันทึกประวัติการเดินทาง (เส้นทาง, ระยะทาง, เวลา) อัตโนมัติ
- 🔦 เครื่องมือเอาตัวรอดพื้นฐาน (ไฟฉายเปิดด่วนจากหน้า Dashboard)
- 📐 สถาปัตยกรรม Clean Architecture และ BLoC Pattern เพื่อความเสถียรของระบบ

---

# 🚀 ตัวอย่างการทำงานของแอป

## 📡 Offline Radar & Tracking

เมื่อเข้าร่วมห้อง เรดาร์จะแสดงตำแหน่งของเพื่อนร่วมทริปแบบเรียลไทม์ พร้อมบอกระยะห่าง (เมตร) และทิศทางที่เพื่อนอยู่ โดยอ้างอิงจากการหมุนเข็มทิศของผู้ใช้อัตโนมัติ

<img width="1080" height="2400" alt="Screenshot_20260520_191426" src="https://github.com/user-attachments/assets/050132d6-bd15-4a9b-ac8d-84349ca43c5a" />



---

## 🚨 Emergency SOS & Safety Alerts

ความปลอดภัยคือหัวใจหลัก หากลูกทริปคนใดเดินห่างจากกลุ่มเกิน 80 เมตร ระบบจะแสดงเตือน (Proximity Alert) ทันที และในกรณีฉุกเฉิน ผู้ใช้สามารถกดปุ่ม SOS เพื่อส่งสัญญาณขอความช่วยเหลือ บังคับให้อุปกรณ์ของทุกคนในห้องแจ้งเตือนและสั่นเตือนพร้อมกัน

<img width="1080" height="2400" alt="ภาพ" src="https://github.com/user-attachments/assets/886b1088-2032-4c3a-8b11-1b5c1932ea6e" />

<img width="1080" height="2400" alt="ภาพ" src="https://github.com/user-attachments/assets/6980f168-bcc4-4d35-bd5a-9ab4b880ae56" />

---

## 🗺️ Trip History Logging

เมื่อจบทริป (Host ปิดห้อง) ระบบจะสรุปข้อมูลการเดินทางทั้งหมด เช่น เวลาเริ่มต้น-สิ้นสุด, ระยะทางรวม (คำนวณจาก Haversine formula) และรายชื่อผู้ร่วมทริป บันทึกลง Local Database ทันที

https://github.com/user-attachments/assets/placeholder-video-history

---

# 🌟 ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|----------|-------------|
| 📡 P2P Connectivity | สร้างห้องและเชื่อมต่ออุปกรณ์หากันโดยตรง ไม่ใช้อินเทอร์เน็ต |
| 🧭 Smart Radar | เรดาร์ติดตามพิกัดเพื่อนร่วมทริป อิงตามเข็มทิศและ GPS |
| ⚠️ Proximity Alert | แจ้งเตือนอัตโนมัติเมื่อสมาชิกในกลุ่มอยู่ห่างเกินระยะปลอดภัย (80m) |
| 🚨 SOS Broadcast | ส่งสัญญาณฉุกเฉินแบบกระจายตัว (Broadcast) ไปยังทุกคนในทริป |
| 💓 Keep-Alive System | ตรวจสอบสถานะการเชื่อมต่อ (Ping/Pong) ทุก 5-10 วินาที |
| 🗺️ Auto Trip Logging | บันทึกสถิติและเส้นทางการเดินป่าลง Isar Database อัตโนมัติ |
| 📸 Base64 Image Sync | บีบอัดและแปลงรูปโปรไฟล์เพื่อส่งผ่าน P2P ให้ประหยัดแบนด์วิดท์ที่สุด |

---

# 🛠 เทคโนโลยีที่ใช้

| หมวดหมู่ | เทคโนโลยี |
|----------|-----------|
| ภาษา | Dart, Kotlin (Native Bridge) |
| UI Framework | Flutter |
| สถาปัตยกรรม | Clean Architecture |
| State Management | BLoC & Cubit |
| ฐานข้อมูล | Isar (NoSQL) |
| ฮาร์ดแวร์ & เซนเซอร์ | Geolocator, Flutter Compass, Torch Light |
| การสื่อสาร P2P | Android Nearby Connections API |
| Routing | GoRouter (StatefulShellRoute) |
| การส่งข้อมูลข้ามแพลตฟอร์ม | MethodChannel & EventChannel |

---

# 🏛️ สถาปัตยกรรมของระบบ

TrailGuide ถูกพัฒนาด้วย **Clean Architecture** แบ่งแยกการทำงานเป็นชั้น Data, Domain และ Presentation อย่างชัดเจน และมีการเขียน Native Bridge เพื่อให้ Flutter สามารถคุยกับ Android API ได้โดยตรง

```text
                 Flutter UI (Presentation)
                       │
                       ▼
             BLoC / Cubit (State Management)
                       │
                       ▼
                 Domain Use Cases 
         (e.g., WatchPeers, CalculateDistance)
           ┌───────────┴───────────┐
           ▼                       ▼
    P2P Repository           History Repository
           │                       │
           ▼                       ▼
 ┌───────────────────┐    ┌───────────────────┐
 │ Native P2P Source │    │ Isar Local Source │
 └─────────┬─────────┘    └───────────────────┘
           │
           ▼
 Android Nearby Connections
(MethodChannel / EventChannel)
