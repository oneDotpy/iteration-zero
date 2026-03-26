# MemoryCare: Caregiver x Care Recipient — by Iteration Zero

> *"Connection, not correction."*

A Flutter prototype for a caregiver support app, built for CSC318. The app has two sides: one for **caregivers** managing their loved ones, and one for **care recipient** seeking comfort and reassurance.

**Two versions available:**
- **`app/`** — Demo version with in-memory state (no backend)
- **`app_db/`** — Full version with Firebase backend, real-time updates, and persistent storage

---

## Research-driven design

This app is built on user research with **caregivers and care recipients** affected by cognitive decline. Key insights informed our design:

- **Care recipients need reassurance, not correction** — personalized messages from trusted caregivers provide comfort during moments of confusion
- **Caregivers need quick access to guidance** — evidence-based information on common behaviors (sundowning, wandering, repetitive questions)
- **Moments of confusion are emotional** — breathing exercises and familiar voices help calm and ground care recipients
- **Accessibility is essential** — high contrast modes, text scaling, and reduced motion options support users with visual and sensory needs

The prototype prioritizes **connection and dignity** over surveillance or control.

---

## What it does

### Caregiver side
- **Get some guidance** — browse topics (sundowning, wandering, repetitive questions, etc.) and read evidence-based guidance. A done screen ("Happy to help.") lets you get more guidance or return home.
- **Send reassurance** — compose a headline, subtext, and simulated voice recording for a specific care recipient and situation. Supports multiple care recipients and multiple situation types per message. After saving, the form clears and shows a "Reassurance sent!" confirmation with an option to send another.
- **Take a breather** — a 3-cycle guided breathing exercise with an animated inner circle (inhale → hold → exhale). Progress dots track cycles; a done screen offers to continue or finish.
- **Manage care recipients** — add, edit, and remove care recipients from your care list. Each care recipient gets their own reassurance message store.

### Care Recipient side
- **I feel unsure** — choose what's happening right now (time, place, person, or general confusion) and receive the reassurance message your caregiver prepared.
- **Hear a familiar voice** — play back the simulated voice recording your caregiver recorded.
- **Take a breather** — same guided breathing exercise as the caregiver side.

### Shared features
- Simulated voice input bar on home screens and the "I feel unsure" screen — tap to enter listening mode, see a live timer and animated waveform, tap Done or wait 10 s. Shows "Got it!" confirmation before returning to idle.
- Sign up (caregiver or care recipient role) or log in — accounts persist for the app session.
- **Settings** — dark mode, high contrast, text size (S/M/L), reduced motion. All settings take effect immediately app-wide.

---

## Demo accounts

| Role      | Email                    | Password    |
|-----------|--------------------------|-------------|
| Caregiver | caregiver@gmail.com      | caregiver   |
| Patient   | patient@gmail.com        | patient     |

You can also create new accounts via **Create an account** — they are saved in memory for the session and can be used to log back in.

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.41+, Dart 3.11+ |
| **State management** | ValueNotifier, Provider pattern |
| **Backend** (app_db only) | Firebase Firestore, Firebase Storage |
| **Authentication** | Firebase Authentication |
| **Push notifications** | Firebase Cloud Messaging (FCM) |
| **Cloud functions** | Firebase Cloud Functions (Node.js) |
| **Audio** | audioplayers plugin |
| **Video** | video_player plugin |
| **Image** | image_picker plugin |
| **Accessibility** | Flutter's built-in MediaQuery APIs, custom animation controls |

---

## Project structure

```
iteration-zero/
├── Paper Prototype/        # Original paper prototype PNGs
├── app/                    # Flutter project (demo, no backend)
│   └── lib/
│       ├── main.dart                   # App entry; themeNotifier + settingsNotifier
│       ├── app_state.dart              # All static app state, auth & AppSettings
│       ├── screens/
│       │   ├── welcome_screen.dart
│       │   ├── login_screen.dart
│       │   ├── create_account_screen.dart
│       │   ├── caregiver_home_screen.dart
│       │   ├── patient_home_screen.dart
│       │   ├── guidance_topic_screen.dart
│       │   ├── guidance_result_screen.dart
│       │   ├── guidance_done_screen.dart
│       │   ├── send_reassurance_screen.dart
│       │   ├── send_reassurance_done_screen.dart
│       │   ├── manage_patients_screen.dart
│       │   ├── breather_intro_screen.dart
│       │   ├── breathing_screen.dart
│       │   ├── breathing_done_screen.dart
│       │   ├── patient_situation_screen.dart
│       │   └── patient_reassurance_screen.dart
│       ├── theme/
│       │   ├── app_colors.dart         # Light / dark / high-contrast palettes
│       │   └── app_theme.dart          # ThemeData builders
│       └── widgets/
│           ├── animated_waveform.dart  # Animated bar waveform (respects reduced motion)
│           ├── breathing_circle.dart   # Animated breathing circle widget
│           ├── soft_card.dart
│           ├── soft_text_field.dart
│           └── voice_input_bar.dart    # Tappable voice input simulation
├── app_db/                 # Flutter project (full version with Firebase)
│   ├── lib/                # Same structure as app/ plus:
│   │   └── services/
│   │       ├── firebase_service.dart   # Firebase operations
│   │       └── widget_service.dart     # Platform-specific features
│   ├── functions/          # Cloud Functions for FCM notifications
│   ├── firebase.json       # Firebase configuration
│   └── .firebaserc         # Firebase project reference
```

---

## How to run

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41+ recommended)
- Dart 3.11+
- For iOS Simulator: Xcode installed and configured
- For Android: Android Studio + an emulator or physical device
- For **app_db** only: Firebase CLI (`npm install -g firebase-tools`)

Verify your setup:
```bash
flutter doctor
```

### Choose your version

**Demo (no backend):**
```bash
cd app
flutter pub get
```

**Full version with Firebase:**
```bash
cd app_db
flutter pub get
firebase login
```

### Run options

**In Chrome (quickest, no setup needed):**
```bash
flutter run -d chrome
```
Then open Chrome DevTools → toggle Device Toolbar (Ctrl/Cmd+Shift+M) and select a phone preset like iPhone 12 Pro.

**In iOS Simulator:**
```bash
open -a Simulator
flutter run -d ios
```

**In Android Emulator:**
```bash
flutter emulators --launch <emulator_id>
flutter run -d android
```

**List available devices:**
```bash
flutter devices
```

### Build a web release

```bash
flutter build web
```
Output is in `app/build/web/` — open `index.html` in any browser.

---

## Notes

### app/ (demo version)
- All state lives in memory and resets when the app is closed.
- Voice recording and playback are simulated — no audio is captured or stored.

### app_db/ (Firebase version)
- **Persistent storage** — all data is saved to Firebase Firestore and syncs across devices.
- **Real-time updates** — reassurance messages and alerts update instantly for both caregiver and care recipient.
- **Push notifications** — caregivers receive notifications via FCM when care recipients exceed usage thresholds.
- **Cloud Functions** — automatic notification delivery when alerts are triggered.

### Both versions
- The breathing exercise is limited to **3 cycles** by design.
- **Accessibility settings** apply immediately app-wide via `settingsNotifier` (a `ValueNotifier<int>`) that triggers a full widget tree rebuild. Text scaling uses Flutter's `MediaQuery.textScaler`; high contrast swaps the entire `AppColors` palette; reduced motion disables animated waveforms and page transitions and replaces the breathing circle animation with a countdown.
