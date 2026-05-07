# SkillSpryng — iOS Application
**16115859| COBSCCOMP24.2P-019 | M.S.F.Shazna**  
BSc (Hons) Computing — NIBM / Coventry University  
Peer-to-Peer Skill Exchange Platform for iOS

---

## Overview

SkillSpryng is an iOS app that connects people who want to teach a skill with people who want to learn one. Users can discover nearby instructors, book one-on-one sessions (online or in-person), join live video calls, earn SKP reward credits, and track their learning progress — all in one place.

---

## Requirements

| Tool | Version |
|---|---|
| Xcode | 16.0 or later |
| iOS Deployment Target | 18.0+ |
| Swift | 5.10 |
| macOS (build machine) | Sonoma 14.0 or later |
| Firebase iOS SDK | Integrated via Swift Package Manager |

---

## Project Structure

```
SkillSpring/
├── SkillSpringApp.swift        # App entry point
├── Accessibility/              # AccessibilityHelper modifiers
├── Assets.xcassets/            # Images, icons, colours
├── CoreData/                   # PersistenceController + data model
├── DesignSystem/               # AppTheme — colours, typography, spacing
├── Models/                     # Swift structs (User, Session, Course, etc.)
├── Services/                   # Firebase, Location, StoreKit, Notifications, etc.
├── ViewModels/                 # MVVM view models (@MainActor, ObservableObject)
├── Views/                      # SwiftUI views (Auth, Home, Sessions, Rewards, etc.)
└── SupportingFiles/            # GoogleService-Info.plist, StoreKit config, GPX files
SkillSpringTests/               # 93 XCTest unit tests
SkillSpringUITests/             # XCUITest UI tests
```

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone <repo-url>
cd COBSCCOMP24.2P-019_SkillSpryng
```

### 2. Open in Xcode

Double-click `SkillSpring.xcodeproj` or open via **File → Open** in Xcode.

### 3. Configure Firebase

The file `SkillSpring/SupportingFiles/GoogleService-Info.plist` is required for Firebase.  
This file contains project-specific API keys and is **not committed to the repository**.

To configure:
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Register the iOS app with bundle ID `com.nibm.SkillSpring`
3. Download `GoogleService-Info.plist` and place it in `SkillSpring/SupportingFiles/`
4. Enable **Phone Authentication** under Firebase → Authentication → Sign-in methods
5. Create a **Firestore Database** (start in test mode, then apply security rules)
6. Create a **Firebase Storage** bucket

### 4. Configure StoreKit (Sandbox Testing)

In-app purchases use the local StoreKit configuration file:  
`SkillSpring/SupportingFiles/LocalStore.storekit`

This is pre-configured with:
- `com.skillspryng.pro.monthly` — Pro Monthly subscription
- `com.skillspryng.pro.yearly` — Pro Yearly subscription
- Credit pack products

No additional setup is required for simulator testing.

### 5. Select a Simulator or Device

The app targets **iPhone** (iOS 18+). Recommended simulators:
- iPhone 16 Pro
- iPhone 15

> **Note:** Features requiring hardware (Face ID, Camera, GPS geofencing) must be tested on a physical device.

### 6. Build & Run

Select the `SkillSpring` scheme and press **⌘R**.

---

## Running Tests

### Unit Tests (93 tests)
```
⌘U  or  Product → Test
```
Covers: Auth, Booking, Chat, Calendar, Geofence, Persistence (in-memory), StoreKit, Firebase data models, and more.

### UI Tests
```
Select SkillSpringUITests scheme → ⌘U
```
Covers: Onboarding flow, login, tab navigation, Discover search, chat message send.

---

## Key Features

| Feature | Technology |
|---|---|
| Phone OTP Authentication | Firebase Auth |
| Biometric Login (Face ID / Touch ID) | LocalAuthentication framework |
| Instructor Discovery + Map | MapKit, CoreLocation |
| Session Booking & Calendar Sync | EventKit, Firestore |
| Geofence Safety Monitoring | CoreLocation CLCircularRegion |
| Live Video Sessions | WKWebView + Jitsi Meet |
| In-App Camera / Media | AVFoundation |
| Real-time Messaging | Firestore real-time listeners |
| Offline Profile Caching | Core Data |
| SKP Rewards & Leaderboard | Firestore |
| Premium Subscriptions & Credits | StoreKit 2 |
| Push Notifications | UserNotifications framework |
| Network Monitoring | Network framework (NWPathMonitor) |
| Accessibility | AccessibilityHelper, Dynamic Type, VoiceOver labels |

---

## Architecture

**MVVM** with protocol-based dependency injection.

- `FirebaseService` and `DataService` protocols allow all ViewModels to be tested with mock implementations.
- `AppTheme` is the single source of truth for all colours, typography, and spacing — all fonts use Dynamic Type semantic styles.
- `@MainActor` is applied to all ViewModels to ensure UI updates happen on the main thread.

---

## Permissions Used

| Permission | Usage Description |
|---|---|
| NSCameraUsageDescription | Profile picture capture |
| NSMicrophoneUsageDescription | Live video learning sessions |
| NSPhotoLibraryUsageDescription | Profile picture selection |
| NSLocationWhenInUseUsageDescription | Show nearby instructors |
| NSLocationAlwaysAndWhenInUseUsageDescription | Background geofence session monitoring |
| NSFaceIDUsageDescription | Biometric login |
| NSCalendarsFullAccessUsageDescription | Session scheduling and conflict detection |

All permissions are declared in the project build settings (`GENERATE_INFOPLIST_FILE = YES`).

---

## App Flow

The user journey follows a linear onboarding path before arriving at the main tab experience:

```
Launch
  └── Onboarding (4 screens)
        └── Phone OTP Authentication
              └── Skill Setup (teach / learn / experience / location / photo)
                    └── Main App (Tab Bar)
                          ├── Home          — personalised feed, recommended sessions & courses
                          ├── Discover      — search instructors, map view, filter by skill
                          ├── Sessions      — upcoming, past, and pending bookings
                          ├── Messages      — real-time conversations with instructors/learners
                          └── Profile       — wallet, rewards, settings, biometric toggle
```

---

## Navigation Structure

| Tab | Key Views |
|---|---|
| **Home** | Recommended skills, featured courses, upcoming session card, quick actions |
| **Discover** | Instructor search, MapKit full-screen map, skill filter chips, match profiles |
| **Sessions** | My Sessions list (filter: upcoming / past / pending), Session Detail, Booking flow, Live Session (Jitsi), Rate Session sheet |
| **Messages** | Conversation list (today / yesterday / earlier), real-time chat, notification inbox |
| **Profile** | Profile card, Wallet (SKP balance + transaction history), Rewards & leaderboard, Premium upgrade, Settings (biometric, notifications, logout, delete account) |

---

## Firestore Data Model

| Collection | Purpose |
|---|---|
| `users` | User profile documents — skills, bio, location, wallet balance, karma points |
| `sessions` | Booking records — instructor, learner, date, time, status, rating, feedback |
| `conversations` | Messaging threads — participant IDs, last message preview, timestamp |
| `messages` | Individual chat messages inside a conversation — text, sender, timestamp |
| `courses` | Structured learning content — title, instructor, modules, difficulty level |
| `events` | Community skill events — venue, date, attendee count |
| `reviews` | User-to-user reviews submitted after a completed session |

---

## Design System

All UI is built on `AppTheme` — a single source of truth for colours, typography, and spacing.

| Token | Value |
|---|---|
| Primary Brand Colour | `#1D9E75` (green) |
| Accent / Gradient End | `#27E246` |
| Typography | All Dynamic Type semantic styles (`Font.headline`, `Font.body`, etc.) — scales with Accessibility → Larger Text |
| Spacing scale | `xs` 4pt · `sm` 8pt · `md` 16pt · `lg` 24pt · `xl` 32pt · `xxl` 48pt |
| Corner radius | 12pt (cards), 32pt (balance card), 50% (avatars) |

No hardcoded font sizes are used in primary UI text. Decorative icons use `.largeTitle` / `.title` system styles.

---

## Geofencing — Simulator Testing

The project includes two GPX route files for simulating location movement in the iOS Simulator:

| File | Purpose |
|---|---|
| `geofence_test.gpx` | Generic route that exits a 500 m session geofence boundary |
| `colombo_geofence_test.gpx` | Route centred on Colombo, Sri Lanka — matches seeded session venues |

**To test in Simulator:**
1. Run the app and navigate to an active in-person session
2. In the Simulator menu bar: **Features → Location → Custom Location…** or select the GPX file via **Features → Location → [GPX file name]**
3. When the simulated location exits the 500 m geofence, `GeofenceManager` triggers the Safety Alert sheet automatically

---

## Known Limitations & Future Work

| Area | Status |
|---|---|
| SOS / Emergency contact API | UI alert exists; API integration is a planned future enhancement |
| Delete Account API | Confirmation dialog exists; backend deletion endpoint is a future task |
| Map region | Currently seeded with Sri Lanka / Colombo data; region is configurable via `DataSeeder` |
| Jitsi Meet rooms | Room names are generated from session IDs; production deployment requires a self-hosted Jitsi instance or 8x8 API key |
| Child Mode | Toggle exists in settings; content filtering rules are a future enhancement |

---

## Student Details

| Field | Detail |
|---|---|
| Student Name | M.S.F.Shazna |
| Student ID | COBSCCOMP24.2P-019 |
| Module | Mobile Application Development — CW2 |
| Institution | NIBM / Coventry University |
