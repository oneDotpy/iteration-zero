# Iteration Zero | CSC318

> "Connection, not correction."

A Flutter prototype designed to support emotionally safe interactions between caregivers and individuals experiencing memory loss.

---

## Overview

The app includes two perspectives:
- **Caregiver** — guidance, reassurance tools, and care management
- **Care Recipient** — simple, calming interactions for reassurance

---

## Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Caregiver | caregiver@gmail.com | caregiver |
| Care Recipient | patient@gmail.com | patient |

---

## Project Structure
```
iteration-zero/
├── app/        # Demo version (no backend)
├── app_db/     # Full version (Firebase)
└── Paper Prototype/
```

---

## How to Run (VS Code + iPhone 16e Simulator)

### 1. Prerequisites

- Flutter SDK (3.41+)
- Dart (3.11+)
- Xcode (for iOS Simulator)
- VS Code with Flutter & Dart extensions

Check setup:
```bash
flutter doctor
```

### 2. Clone Repository
```bash
git clone https://github.com/oneDotpy/iteration-zero.git
cd iteration-zero/app
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run on iPhone 16e Simulator

Start simulator:
```bash
open -a Simulator
```

In VS Code:
1. Open the project folder
2. Select device → **iPhone 16e**
3. Run:
```bash
flutter run
```

---

### Tools & Development Notes
AI coding assistants (ChatGPT, GitHub Copilot, and Claude) were used during development, primarily for generating setup code, debugging Flutter-specific issues, and assisting with parts of the UI implementation. All design decisions, app structure, interaction logic, user research, and feedback-driven design iterations were our own.
