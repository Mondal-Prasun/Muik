# 🎵 Muik - Music App

![License](https://img.shields.io/github/license/Mondal-Prasun/Muik?color=blue)
![Stars](https://img.shields.io/github/stars/Mondal-Prasun/Muik?style=social)
![Forks](https://img.shields.io/github/forks/Mondal-Prasun/Muik?style=social)
![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)
![Framework](https://img.shields.io/badge/UI-Flutter-02569B?logo=flutter)
![Native Engine](https://img.shields.io/badge/Audio%20Engine-Kotlin%20%2F%20Media3-7F52FF?logo=kotlin)

**Muik** is a lightweight, responsive music app featuring a modern **Flutter** user interface powered by a high-performance native **Android Kotlin (Media3/ExoPlayer)** background engine connected via Platform Channels.

---

## 📱 App Preview

| App Interface | Playback Demo | Feature Demo |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/79c7ef99-96b1-4254-a853-5cc4a19b6b47" width="250" alt="Muik Interface"/> | <video src="https://github.com/user-attachments/assets/5e1ccd61-f1cf-490f-8bf6-51859dabbd52" width="250" alt="Screen Recording 1"/> | <video src="https://github.com/user-attachments/assets/5f8ffe8d-5a24-4f22-a776-3dba00da4985" width="250" alt="Screen Recording 2"/> |
| **Main Interface** | **Player & Controls** | **Choose** |

---

## ⚡ Architecture Overview

Muik combines the best of cross-platform UI development with native Android audio management:

* **Frontend (Flutter)**: Handles UI layout, state management, reactive user interactions, and fluid animations.
* **Backend (Native Kotlin)**: Runs a dedicated `MediaSessionService` using **Android Jetpack Media3** for rock-solid audio playback, media notification controls, and hardware volume/headset event handling.
* **Bridge (Platform Channels / MethodChannel)**: Provides real-time bidirectional communication between Flutter and Native Kotlin for player states, position updates, and controls.

---

## ✨ Features

- **Fluid Flutter UI**: Clean, expressive, and highly responsive user interface.
- **Native Media3 Engine**: Powered by Jetpack Media3 for low-latency audio processing and seamless streaming/playback.
- **Background Playback & Foreground Service**: Keeps music playing reliably in the background without getting killed by system battery optimization.
- **Lock Screen & Notification Controls**: Native media controls integrated with Android System UI.
- **Local Media Scanner**: Automatic indexing of local audio files stored on device storage.
- **Playlists & Queue Management**: Create custom playlists and manage on-the-fly playback queues.

---

## 🛠️ Tech Stack

* **UI Layer**: [Flutter](https://flutter.dev/) (Dart)
* **Native Audio Engine**: [Kotlin](https://kotlinlang.org/) + [Jetpack Media3 (ExoPlayer)](https://developer.android.com/guide/topics/media/media3)
* **Communication**: Flutter `MethodChannel` & `EventChannel`
* **State Management**: Riverpod

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.x or higher
- **Android Studio** (Ladybug or newer recommended)
- **Java Development Kit (JDK)**: 17
- **Target Device**: Android 7.0 (API Level 24) or higher


### Installation & Run

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Mondal-Prasun/Muik.git
   cd Muik
   ```
