<p align="center">
  <img width="363" alt="TrailGuide Logo" src="https://github.com/user-attachments/assets/d141d71f-eb0b-4de7-8a4c-b0db04ce7627" />
</p>

<h1 align="center">
  TrailGuide
</h1>

<p align="center">
  <strong>A Flutter application for hiking and outdoor adventures that enables offline location tracking, communication, and emergency alerts through Peer-to-Peer networking.</strong>
</p>

<p align="center">
  Designed with an <strong>Offline-First</strong> architecture, TrailGuide establishes direct <strong>Peer-to-Peer (P2P)</strong> connections between nearby devices without requiring an internet connection or centralized server, making it ideal for remote and low-signal environments.
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

# 📖 Project Overview

TrailGuide is a Flutter-based mobile application designed to improve safety and communication during hiking trips and outdoor activities where internet connectivity is unavailable.

The application leverages the **Android Nearby Connections API** over **Bluetooth** and **Wi-Fi Direct** to establish an offline Peer-to-Peer network, enabling real-time sharing of GPS locations, compass directions, and emergency messages among group members.

Trip history, routes, and statistics are stored locally using **Isar Database**, allowing the application to operate entirely offline while ensuring user privacy.

---

# ✨ Technical Highlights

- 📡 Offline Peer-to-Peer Communication
- 🧭 Real-time GPS Tracking & Smart Radar
- 🚨 Emergency SOS Broadcasting
- ⚠️ Automatic Proximity Alerts
- 🗺️ Offline Trip History Logging
- 💾 Local Storage with Isar Database
- 🏛️ Clean Architecture with BLoC Pattern

---

# 🚀 App Showcase

## 📍 Dashboard

Displays GPS status, provides quick flashlight access, and introduces the application's core features.

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/36309ff7-da1d-4004-8399-ff1b9ece1046"/>
</p>

---

## 📡 Offline Radar Tracking

Once users join the same room, TrailGuide displays each member's position in real time by combining GPS coordinates with compass heading to calculate distance and direction.

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/050132d6-bd15-4a9b-ac8d-84349ca43c5a"/>
</p>

---

## 🚨 Emergency SOS & Safety Alerts

TrailGuide continuously monitors the distance between group members. When someone moves beyond the predefined safety range, an automatic proximity alert is triggered.

In emergency situations, users can broadcast an SOS signal that immediately notifies every connected device with both visual and vibration alerts.

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/886b1088-2032-4c3a-8b11-1b5c1932ea6e"/>
  &nbsp;&nbsp;&nbsp;
  <img width="250" src="https://github.com/user-attachments/assets/6980f168-bcc4-4d35-bd5a-9ab4b880ae56"/>
</p>

---

## 🗺️ Trip History

At the end of each trip, TrailGuide automatically records travel statistics—including duration, total distance, route information, and participant details—into the local database for future reference.

<p align="center">
  <img width="250" src="https://github.com/user-attachments/assets/1f43464f-eb90-44b1-8ee7-58ec75824c52"/>
</p>

---

# 🌟 Features

| Feature | Description |
|----------|-------------|
| 📡 Offline P2P Communication | Direct device-to-device communication via Bluetooth and Wi-Fi Direct without internet access |
| 🧭 Smart Radar | Real-time radar visualization using GPS coordinates and compass heading |
| ⚠️ Proximity Alert | Automatically warns users when teammates move beyond the safe distance threshold |
| 🚨 SOS Broadcast | Instantly broadcasts emergency alerts to every connected group member |
| 💓 Keep-Alive Monitoring | Continuously monitors peer connectivity using a Ping/Pong mechanism |
| 🗺️ Trip History | Automatically records hiking statistics and routes using Isar Database |
| 📷 Profile Image Sync | Compresses and transfers profile images efficiently over the P2P network |

---

# 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Language | Dart, Kotlin (Native Bridge) |
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

# 🏛️ Architecture

TrailGuide follows **Clean Architecture**, clearly separating the Presentation, Domain, and Data layers. Native Android functionality is exposed to Flutter through platform channels, allowing direct access to the Nearby Connections API.

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

# 📂 Project Structure

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

| Folder | Responsibility |
|----------|---------------|
| core | Shared utilities, application configuration, themes, and common components |
| history | Trip history management using Isar |
| onboarding | User profile setup and onboarding flow |
| p2p | Peer-to-Peer communication and room management |
| profile | User profile features |
| settings | Application settings |
| tracking | GPS tracking and location calculations |

---

# 🔄 P2P Data Flow

```text
📱 Device A (Host)                   📱 Device B (Member)
        │                                    │
 📡 Start Advertising                 📡 Start Discovery
        │                                    │
        ├──────── 🤝 Handshake & PIN ────────┤
        │                                    │
 📍 Send GPS (LOC:HOST,Lat,Lng) ─────▶ 📍 Receive GPS Data
        │                                    │
 🧮 LocationCalculator                🧮 LocationCalculator
 (Distance & Bearing)                 (Distance & Bearing)
        │                                    │
 🧭 Merge Compass + GPS               🧭 Merge Compass + GPS
        │                                    │
 🎯 Update Radar UI                   🎯 Update Radar UI
```

---

# ⚙️ Engineering Challenges

| Challenge | Solution | Result |
|-----------|----------|--------|
| Unexpected P2P disconnections | Keep-Alive (Ping/Pong) mechanism | Automatically detects disconnected peers |
| Compass instability and sensor noise | Low-pass filtering | Smoother and more accurate radar rotation |
| Flutter-to-Android communication | EventChannel streaming | Real-time bidirectional data transfer |
| Large profile image size | Image compression + Base64 encoding | Faster P2P transmission with reduced bandwidth usage |
| Continuous GPS tracking | Stream processing with Isar | Efficient route recording and local persistence |

---

# 🚀 Getting Started

```bash
git clone https://github.com/MarkCnw/TrailGuide.git
cd TrailGuide
flutter pub get
flutter run
```
