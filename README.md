<p align="center">
  <img width="363" alt="TrailGuide Logo" src="https://github.com/user-attachments/assets/d141d71f-eb0b-4de7-8a4c-b0db04ce7627" />
</p>

<h1 align="center">
  TrailGuide
</h1>

<p align="center">
  <strong>แอปพลิเคชัน Flutter สำหรับการเดินป่าและกิจกรรมกลางแจ้ง ที่ช่วยติดตามตำแหน่ง สื่อสาร และส่งสัญญาณฉุกเฉินผ่านระบบ Peer-to-Peer แบบออฟไลน์</strong>
</p>

<p align="center">
  ออกแบบภายใต้แนวคิด <strong>Offline-First</strong> โดยเชื่อมต่ออุปกรณ์ผ่าน <strong>Peer-to-Peer (P2P)</strong> โดยไม่ต้องใช้อินเทอร์เน็ตหรือเซิร์ฟเวอร์ส่วนกลาง เหมาะสำหรับการใช้งานในพื้นที่ห่างไกลหรือพื้นที่อับสัญญาณ
</p>

<p align="center">

![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)
![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-4CAF50)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue)
![Isar](https://img.shields.io/badge/Database-Isar-orange)

</p>

---

# 📖 ภาพรวมโปรเจกต์

TrailGuide เป็นแอปพลิเคชันบนมือถือที่พัฒนาด้วย **Flutter** เพื่อช่วยแก้ปัญหาการพลัดหลงและการสื่อสารในพื้นที่ที่ไม่มีสัญญาณอินเทอร์เน็ต เช่น ป่า ภูเขา หรือพื้นที่ห่างไกล

ระบบใช้ **Android Nearby Connections API** ผ่าน **Bluetooth** และ **Wi-Fi Direct** เพื่อสร้างเครือข่ายแบบ Peer-to-Peer สำหรับแชร์ตำแหน่ง GPS ข้อมูลเข็มทิศ และข้อความระหว่างสมาชิกในกลุ่มแบบ Real-time

นอกจากนี้ ระบบยังบันทึกประวัติการเดินทางลง **Isar Database** ภายในเครื่องทั้งหมด ทำให้สามารถใช้งานได้แบบ Offline พร้อมรักษาความเป็นส่วนตัวของข้อมูลผู้ใช้อย่างสมบูรณ์

---

# ✨ Technical Highlights

- 📡 Offline Peer-to-Peer Communication
- 🧭 Real-time GPS Tracking & Radar
- 🚨 Emergency SOS Broadcasting
- ⚠️ Automatic Proximity Alert
- 🗺️ Offline Trip History
- 💾 Local Storage with Isar Database
- 🏛️ Clean Architecture + BLoC Pattern

---

# 🚀 ตัวอย่างการทำงานของแอป

## 📍 Dashboard

แสดงสถานะ GPS เปิดไฟฉาย และแนะนำขั้นตอนการใช้งานเบื้องต้นของแอป

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/36309ff7-da1d-4004-8399-ff1b9ece1046"/>
</p>

---

## 📡 Offline Radar Tracking

เมื่อสมาชิกเข้าร่วมห้อง ระบบจะแสดงตำแหน่งของเพื่อนร่วมทริปแบบ Real-time พร้อมคำนวณระยะทางและทิศทางจากข้อมูล GPS และเข็มทิศ

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/050132d6-bd15-4a9b-ac8d-84349ca43c5a"/>
</p>

---

## 🚨 Emergency SOS & Safety Alert

หากสมาชิกอยู่ห่างจากกลุ่มเกินระยะปลอดภัย ระบบจะแจ้งเตือนทันที และสามารถส่งสัญญาณ SOS เพื่อแจ้งเตือนไปยังสมาชิกทุกคนในห้องพร้อมการสั่นเตือน

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/886b1088-2032-4c3a-8b11-1b5c1932ea6e"/>
  &nbsp;&nbsp;&nbsp;
  <img width="250" src="https://github.com/user-attachments/assets/6980f168-bcc4-4d35-bd5a-9ab4b880ae56"/>
</p>

---

## 🗺️ Trip History

เมื่อสิ้นสุดการเดินทาง ระบบจะบันทึกเวลา ระยะทาง เส้นทาง และรายชื่อสมาชิกลงฐานข้อมูลภายในเครื่องโดยอัตโนมัติ

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/1f43464f-eb90-44b1-8ee7-58ec75824c52"/>
</p>

---

# 🌟 ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|----------|-------------|
| 📡 Offline P2P | เชื่อมต่ออุปกรณ์โดยตรงผ่าน Bluetooth และ Wi-Fi Direct |
| 🧭 Smart Radar | แสดงตำแหน่งสมาชิกแบบ Real-time จาก GPS และ Compass |
| ⚠️ Proximity Alert | แจ้งเตือนเมื่อสมาชิกอยู่ห่างเกินระยะปลอดภัย |
| 🚨 SOS Broadcast | ส่งสัญญาณฉุกเฉินไปยังสมาชิกทุกคนในกลุ่ม |
| 💓 Keep-Alive | ตรวจสอบสถานะการเชื่อมต่อแบบต่อเนื่อง |
| 🗺️ Trip History | บันทึกประวัติการเดินทางลง Isar Database |
| 📷 Profile Image Sync | บีบอัดและส่งรูปโปรไฟล์ผ่าน P2P อย่างมีประสิทธิภาพ |

---

# 🛠️ เทคโนโลยีที่ใช้

| หมวดหมู่ | เทคโนโลยี |
|----------|-----------|
| ภาษา | Dart, Kotlin (Native Bridge) |
| Framework | Flutter |
| Architecture | Clean Architecture |
| State Management | BLoC, Cubit |
| Database | Isar |
| GPS | Geolocator |
| Compass | Flutter Compass |
| Flashlight | Torch Light |
| Routing | GoRouter |
| P2P Communication | Android Nearby Connections API |
| Native Integration | MethodChannel & EventChannel |

---

# 🏛️ สถาปัตยกรรมของระบบ

TrailGuide พัฒนาด้วย **Clean Architecture** เพื่อแยกส่วนของ Presentation, Domain และ Data Layer อย่างชัดเจน พร้อมใช้ Native Bridge เชื่อมต่อ Flutter กับ Android API

## Architecture Diagram

```text
                 Flutter UI
                      │
                      ▼
              BLoC / Cubit
                      │
                      ▼
               Domain Use Cases
          ┌──────────┴──────────┐
          ▼                     ▼
   P2P Repository       History Repository
          │                     │
          ▼                     ▼
 Nearby Data Source     Isar Data Source
          │
          ▼
 Android Nearby API
(MethodChannel / EventChannel)
```

---

## 📂 Project Structure

```text
lib
│
├── core
│   ├── config
│   ├── constants
│   ├── error
│   ├── theme
│   └── utils
│
├── features
│   ├── history
│   ├── onboarding
│   ├── p2p
│   ├── profile
│   ├── settings
│   └── tracking
│
└── main.dart
```

| โฟลเดอร์ | หน้าที่ |
|----------|----------|
| core | Utility, Theme, Config และ Shared Components |
| history | ระบบจัดเก็บประวัติการเดินทาง |
| onboarding | ข้อมูลผู้ใช้และการเริ่มต้นใช้งาน |
| p2p | ระบบเชื่อมต่อ Peer-to-Peer |
| profile | โปรไฟล์ผู้ใช้ |
| settings | ตั้งค่าการใช้งาน |
| tracking | GPS Tracking และการคำนวณตำแหน่ง |

---

## 🔄 P2P Data Flow

```text
📱 อุปกรณ์ A (Host)                  📱 อุปกรณ์ B (Member)
       │                                   │
 📡 Start Advertising                📡 Start Discovery
       │                                   │
       ├──────── 🤝 Handshake & PIN ───────┤
       │                                   │
 📍 ส่ง GPS (LOC:HOST,Lat,Lng) ───▶ 📍 รับพิกัดและประมวลผล
       │                                   │
 🧮 LocationCalculator               🧮 LocationCalculator
 (คำนวณ Distance & Bearing)          (คำนวณ Distance & Bearing)
       │                                   │
 🧭 Flutter Compass ผสมพิกัด          🧭 Flutter Compass ผสมพิกัด
       │                                   │
 🎯 อัปเดตจุดบน Radar UI             🎯 อัปเดตจุดบน Radar UI
```

---

# ⚙️ ความท้าทายในการพัฒนา

| ความท้าทาย | วิธีแก้ไข | ผลลัพธ์ |
|------------|-----------|----------|
| การเชื่อมต่อ P2P หลุดโดยไม่ทราบสาเหตุ | Keep-Alive (Ping/Pong) | ตรวจจับการหลุดของสมาชิกได้อัตโนมัติ |
| เข็มทิศแกว่งและไม่นิ่ง | Low-pass Filter | การหมุนของเรดาร์นุ่มนวลและแม่นยำขึ้น |
| การสื่อสารระหว่าง Flutter กับ Android | EventChannel | รับส่งข้อมูลแบบ Real-time |
| รูปโปรไฟล์มีขนาดใหญ่ | บีบอัดภาพและแปลงเป็น Base64 | ลดเวลาในการส่งข้อมูลผ่าน P2P |
| การบันทึกข้อมูล GPS ต่อเนื่อง | Stream Processing + Isar | บันทึกเส้นทางได้อย่างมีประสิทธิภาพ |

---

# 🚀 การติดตั้ง

```bash
git clone https://github.com/MarkCnw/TrailGuide.git
cd TrailGuide
flutter pub get
flutter run
```
