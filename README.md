# Caregiver x Patient — by Iteration Zero

> *"Connection, not correction."*

A Flutter prototype for a caregiver support app, built for CSC318. The app has two sides: one for **caregivers** managing their loved ones, and one for **patients** seeking comfort and reassurance.

---

## What it does

### Caregiver side
- **Get some guidance** — browse topics (sundowning, wandering, repetitive questions, etc.) and read evidence-based guidance. A done screen ("Happy to help.") lets you get more guidance or return home.
- **Send reassurance** — compose a headline, subtext, and simulated voice recording for a specific patient and situation. Supports multiple patients and multiple situation types per message. After saving, the form clears and shows a "Reassurance sent!" confirmation with an option to send another.
- **Take a breather** — a 3-cycle guided breathing exercise with an animated inner circle (inhale → hold → exhale). Progress dots track cycles; a done screen offers to continue or finish.
- **Manage patients** — add, edit, and remove patients from your care list. Each patient gets their own reassurance message store.

### Patient side
- **I feel unsure** — choose what's happening right now (time, place, person, or general confusion) and receive the reassurance message your caregiver prepared.
- **Hear a familiar voice** — play back the simulated voice recording your caregiver recorded.
- **Take a breather** — same guided breathing exercise as the caregiver side.

### Shared features
- Simulated voice input bar on home screens and the "I feel unsure" screen — tap to enter listening mode, see a live timer and animated waveform, tap Done or wait 10 s. Shows "Got it!" confirmation before returning to idle.
- Sign up (caregiver or patient role) or log in — accounts persist for the app session.
- **Settings** — dark mode, high contrast, text size (S/M/L), reduced motion. All settings take effect immediately app-wide.

---

## Demo accounts

| Role      | Email                    | Password    |
|-----------|--------------------------|-------------|
| Caregiver | caregiver@gmail.com      | caregiver   |
| Patient   | patient@gmail.com        | patient     |

You can also create new accounts via **Create an account** — they are saved in memory for the session and can be used to log back in.

---

## Project structure

```
iteration-zero/
├── Paper Prototype/        # Original paper prototype PNGs
└── app/                    # Flutter project
    └── lib/
        ├── main.dart                   # App entry; themeNotifier + settingsNotifier
        ├── app_state.dart              # All static app state, auth & AppSettings
        ├── screens/
        │   ├── welcome_screen.dart
        │   ├── login_screen.dart
        │   ├── create_account_screen.dart
        │   ├── caregiver_home_screen.dart
        │   ├── patient_home_screen.dart
        │   ├── guidance_topic_screen.dart
        │   ├── guidance_result_screen.dart
        │   ├── guidance_done_screen.dart
        │   ├── send_reassurance_screen.dart
        |   ├── send_reassurance_done_screen.dart
        │   ├── manage_patients_screen.dart
        │   ├── breather_intro_screen.dart
        │   ├── breathing_screen.dart
        │   ├── breathing_done_screen.dart
        │   ├── patient_situation_screen.dart
        │   └── patient_reassurance_screen.dart
        ├── theme/
        │   ├── app_colors.dart         # Light / dark / high-contrast palettes
        │   └── app_theme.dart          # ThemeData builders
        └── widgets/
            ├── animated_waveform.dart  # Animated bar waveform (respects reduced motion)
            ├── breathing_circle.dart   # Animated breathing circle widget
            ├── soft_card.dart
            ├── soft_text_field.dart
            └── voice_input_bar.dart    # Tappable voice input simulation
```

---

## How to run

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41+ recommended)
- Dart 3.11+
- For iOS Simulator: Xcode installed and configured
- For Android: Android Studio + an emulator or physical device

Verify your setup:
```bash
flutter doctor
```

### Install dependencies

```bash
cd app
flutter pub get
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

- This is a **prototype** — there is no real backend or database. All state lives in memory and resets when the app is closed.
- Voice recording and playback are **simulated** — no audio is actually captured or stored.
- The breathing exercise is limited to **3 cycles** by design.
- **Accessibility settings** apply immediately app-wide via `settingsNotifier` (a `ValueNotifier<int>`) that triggers a full widget tree rebuild. Text scaling uses Flutter's `MediaQuery.textScaler`; high contrast swaps the entire `AppColors` palette; reduced motion disables animated waveforms and page transitions and replaces the breathing circle animation with a countdown.
