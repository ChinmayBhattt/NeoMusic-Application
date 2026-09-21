# 🎵 NeoMusic - Stream the Future of Sound

[![Flutter Version](https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.12.1-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-Riverpod_3-blueviolet)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-brightgreen)](#-architecture--folder-structure)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**NeoMusic** is a modern, high-performance music streaming application built with Flutter & Dart. It features a dark-first aesthetic with glowing neon accents, frosted glassmorphism surfaces, real-time audio streaming via `just_audio`, persistent mini-player, full-screen player with rotating vinyl artwork & live synchronized lyrics, smart search, playlist curation, and local persistence.

---

## ✨ Features

### 🎧 High-Fidelity Audio Engine
- **Playback Powered by `just_audio`**: Real MP3 streaming from high-speed CDNs.
- **Full Player Controls**: Play, pause, seek scrub, skip next, skip previous, shuffle, and 3-state loop (`Off` ➔ `All` ➔ `One`).
- **Reactive Stream Synchronization**: Streams playback position, buffered duration, total duration, and playback state without UI lag.

### 📱 Persistent Floating Mini-Player
- **Seamless Multitasking**: Pinned above the bottom navigation bar across all screens.
- **Interactive Controls**: Displays artwork, track title, artist, live linear progress indicator bar, quick-play/pause, favorite heart toggle, and skip next.
- **Smooth Page Transitions**: Tapping smoothly slides up the immersive full-screen player.

### 💿 Immersive Full-Screen Player
- **Dynamic Animated Artwork**: Rotating vinyl record with groove textures and dynamic glowing neon aura that pulses while playing.
- **Interactive Progress Bar**: Scrub to any second in the song with buffered duration preview.
- **Live Synchronized Lyrics (`LyricsSheet`)**: Real-time line-by-line synced lyrics highlighted in electric cyan with tap-to-seek functionality.
- **Reorderable Queue (`QueueSheet`)**: Drag-and-drop to reorder upcoming tracks, remove songs, or tap to play instantly.

### 🏠 Home & Discovery
- **Personalized Greeting**: Dynamic time-of-day greeting (*"Good morning"*, *"Good afternoon"*, *"Good evening"*) with user's name.
- **Filter Chips**: Filter by genres (*All*, *Cyberwave*, *Synthpop*, *Lo-Fi Beats*, *Deep House*, *Ambient Chill*, etc.).
- **Hero Featured Release**: High-impact gradient banner with direct *"Play Now"* action.
- **Trending Tracks**: Ranked tracks (#1 to #6) with live animated equalizer visualizer for the currently playing track.
- **Popular Artists & Curated Playlists**: Explore top producers with glowing avatar rings and curated mood playlists.

### 🔍 Smart Search & Category Exploration
- **Live Query Filtering**: Instant search across songs, artists, albums, and playlists.
- **Vibrant Genre Cards**: Category cards with rich gradients for visual music discovery.
- **Filter Tabs**: Quickly toggle between *All*, *Songs*, *Artists*, *Albums*, and *Playlists*.

### 📚 Library & Local Persistence
- **Liked Songs Hub**: Dedicated hero card displaying real-time favorite count; likes persist locally across restarts.
- **Custom Playlists**: Create, customize, and delete personal playlists with local persistence using `shared_preferences`.
- **Recently Played History**: Automatically logs listening history and surfaces recent tracks on the Home screen.

### ⚙️ Settings, Audio Profiles & Modular Auth
- **User Profile Management**: Edit display name, view membership status, and manage profile avatar.
- **Audio Quality Presets**: Select between *Normal (160 kbps)*, *High (320 kbps)*, and *Hi-Res Lossless (FLAC 24-bit)*.
- **Equalizer Sound Profiles**: Presets for *Flat*, *Bass Boost*, *Cyber Electronic*, *Acoustic Warmth*, *Vocal Clarity*, and *Rock Energy*.
- **Offline & Network Toggles**: Offline mode switch and cellular streaming toggle.
- **Modular Authentication (`AuthDialog`)**: Decoupled login and sign-up bottom sheet ready for backend integration (Firebase / Supabase / REST).

---

## 🏛 Architecture & Folder Structure

NeoMusic is engineered using **Clean Architecture** to ensure testability, scalability, and loose coupling:

```
lib/
├── core/
│   ├── constants/              # Application constants & storage keys
│   ├── theme/                  # Colors, gradients, typography, and dark theme
│   └── utils/                  # Formatters (durations, counts, dates)
├── domain/
│   ├── models/                 # Pure domain entities (Song, Artist, Album, Playlist, UserProfile)
│   └── repositories/           # Abstract contracts (MusicRepository, PlaylistRepository, AuthRepository)
├── data/
│   ├── datasources/            # MockMusicData (streamable catalog) & LocalStorageDataSource (SharedPreferences)
│   └── repositories/           # Concrete repository implementations with filtering and persistence
├── services/
│   ├── audio_player_service.dart # just_audio wrapper managing playback, queue, and streams
│   └── storage_service.dart    # Persistent storage initialization
└── presentation/
    ├── providers/              # Riverpod 3 NotifierProviders & StreamProviders
    ├── widgets/                # Reusable UI components (SongCard, SongListTile, MiniPlayer, etc.)
    └── screens/
        ├── main_shell_screen.dart # Indexed navigation shell with persistent mini-player
        ├── home/               # Home screen with greeting, hero banner, trending tracks
        ├── search/             # Live search with genre exploration cards
        ├── library/            # Liked tracks, playlists, artists, and albums
        ├── player/             # Full player, lyrics sheet, and queue sheet
        ├── settings/           # Audio quality, equalizer, and preferences
        └── auth/               # Modular login & signup dialog
```

---

## 🛠 Tech Stack & Dependencies

| Category | Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | Cross-platform UI toolkit |
| **Language** | [Dart](https://dart.dev) | Object-oriented client-optimized language |
| **State Management** | [`flutter_riverpod: ^3.4.3`](https://pub.dev/packages/flutter_riverpod) | Reactive, testable state management with `NotifierProvider` |
| **Audio Engine** | [`just_audio: ^0.10.6`](https://pub.dev/packages/just_audio) | Audio playback, stream controls, and queuing |
| **Scrub Bar** | [`audio_video_progress_bar: ^2.0.3`](https://pub.dev/packages/audio_video_progress_bar) | Scrubbable progress bar with buffered duration |
| **Persistence** | [`shared_preferences: ^2.5.5`](https://pub.dev/packages/shared_preferences) | Key-value local storage for favorites, playlists, and settings |
| **Typography** | [`google_fonts: ^8.2.1`](https://pub.dev/packages/google_fonts) | Modern typography (*Outfit* & *Plus Jakarta Sans*) |
| **Image Caching** | [`cached_network_image: ^3.4.1`](https://pub.dev/packages/cached_network_image) | High-speed network image caching and smooth placeholders |
| **Animations** | [`flutter_animate: ^4.5.2`](https://pub.dev/packages/flutter_animate) | Micro-interactions and smooth UI transitions |
| **Utilities** | [`intl: ^0.20.2`](https://pub.dev/packages/intl), [`uuid: ^4.6.0`](https://pub.dev/packages/uuid) | Number formatting and unique ID generation |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.1`)
- Chrome browser, Android Studio / Emulator, or macOS with Xcode Command Line Tools.

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/NeoMusic.git
   cd NeoMusic
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```

4. **Run on macOS Desktop:**
   ```bash
   flutter run -d macos
   ```

5. **Run on iOS / Android:**
   ```bash
   flutter run -d <device_id>
   ```

---

## 🧪 Testing & Code Quality

NeoMusic maintains **100% clean code quality** with zero analysis warnings.

- **Run Static Analysis:**
  ```bash
  flutter analyze
  ```
  *(Expected: `No issues found!`)*

- **Run Automated Tests:**
  ```bash
  flutter test
  ```
  *(Expected: `All tests passed!`)*

---

## 🔌 Future Backend Integration

NeoMusic uses abstract repository contracts that allow you to swap mock data for a real backend in minutes:

- **Music Streaming API**: Implement `MusicRepository` in `lib/data/repositories/` to connect to Spotify Web API, Apple Music API, Jamendo, or your custom REST/GraphQL audio API.
- **Cloud Database & Auth**: Implement `AuthRepository` and `PlaylistRepository` using Firebase (`firebase_auth`, `cloud_firestore`) or Supabase (`supabase_flutter`) to sync playlists and favorites across devices.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
