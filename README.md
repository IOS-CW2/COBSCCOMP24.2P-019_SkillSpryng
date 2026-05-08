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
SkillSpringTests/               # 181 unit tests (16 test files)
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

### Unit Tests (181 tests across 16 files)
```
⌘U  or  Product → Test
```

| Test File | Tests | Covers |
|---|---|---|
| `AuthViewModelTests.swift` | 8 | OTP state machine, Combine async expectations, new/existing user routing |
| `BiometricAndNotificationTests.swift` | 14 | Hardware detection, UserDefaults persistence, notification scheduling guards |
| `BookingViewModelTests.swift` | 11 | Pricing, date parsing, insufficient funds, payment sheet, free request flow |
| `CalendarServiceTests.swift` | 9 | Conflict detection, `DateInterval.intersects`, iOS 17 access path |
| `ChatViewModelTests.swift` | 8 | Message send, optimistic UI, read marking |
| `DiscoverViewModelTests.swift` | 14 | Search filter, category filter, map annotation, match % |
| `FirebaseDataServiceModelTests.swift` | 7 | Codable model round-trips, field mapping |
| `GeofenceManagerTests.swift` | 8 | Exit/re-entry state machine, 5-min escalation timer, Firestore log |
| `LearningViewModelTests.swift` | 18 | Course filter, enrolment, progress clamping, events |
| `MessagesViewModelTests.swift` | 13 | Conversation load, message send, soft delete, unread count |
| `PersistenceTests.swift` | 3 | In-memory Core Data upsert, fetch, clear |
| `ProfileViewModelTests.swift` | 18 | Profile completeness, skill arrays, wallet balance, stats |
| `RewardsViewModelTests.swift` | 12 | Leaderboard derivation, mastery clamping, milestone integrity |
| `SessionsViewModelTests.swift` | 13 | Upcoming/completed/cancelled filters, todaySession, tomorrowSession |
| `SkillSpringTests.swift` | 12 | MockDataProvider data integrity, AnalyticsData, MapViewModel |
| `StoreKitServiceTests.swift` | 13 | Credit calculation, entitlement checks, `VerificationResult` unwrapping |

### UI Tests (8 tests)
```
Select SkillSpringUITests scheme → ⌘U
```

| Test | Verifies |
|---|---|
| `test_launch_showsOnboardingAfterDelay` | LaunchView → Onboarding navigation |
| `test_loginFlow_navigatesToOTPVerification` | Full name → phone → OTP screen |
| `test_tabBarNavigation_switchesTabsSuccessfully` | All 4 tabs navigable without crash |
| `test_discoverSearch_noResults_showsEmptyState` | Search empty state |
| `test_chat_sendMessage_appearsInBubble` | Optimistic UI after message send |
| `test_matchDetail_tapBookSession_opensbookingView` | Connect → Match → Book flow |
| `test_accessibility_keyElementsHaveLabels` | VoiceOver labels on key elements |
| `test_offlineBanner_appearsWhenNoNetwork` | Network Link Conditioner / manual test |

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

## Advanced iOS Features

The following five advanced iOS framework integrations are implemented in full and are demonstrable during the VIVA:

| # | Framework | Integration Depth |
|---|---|---|
| 1 | **LocalAuthentication** | `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)` — all 5 `LAError` cases handled (userCancel, biometryLockout, authenticationFailed, biometryNotEnrolled, biometryNotAvailable). Fresh `LAContext` created per-attempt to avoid silent failure. Biometric toggle persisted in `UserDefaults`. |
| 2 | **EventKit** | 8-function `CalendarService` — `requestFullAccessToEvents` (iOS 17) with legacy fallback, `EKStructuredLocation` with 500 m radius for time-to-leave alerts, deep-link `URL` (`skillspryng://session/ID`) embedded in every event, dual `EKAlarm` (1 hr + 24 hr), conflict detection via `getBusyTimeSlots` + `isTimeSlotAvailable`. |
| 3 | **MapKit + CoreLocation** | `MKLocalSearch` for venue lookup, `Map()` with `MapAnnotation` for custom instructor pins, `CLGeocoder` for address resolution, `CLCircularRegion` (500 m) geofence for in-person session safety monitoring. |
| 4 | **CoreLocation Geofencing** | `CLLocationManager.startMonitoring(for:)` with `CLCircularRegion`. `locationManager(_:didExitRegion:)` fires `GeofenceManager.handleExit()` → safety alert sheet → 5-minute escalation timer → Firestore audit log → local push notification. |
| 5 | **StoreKit 2** | `Product.products(for:)` async load, `product.purchase()` with `Transaction.updates` listener, `VerificationResult<Transaction>` unwrapping (no custom validation server), consumable credit pack purchases, auto-renewing Pro subscription with `checkSubscriptionStatus()` on every launch. |

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

| Area | Current Status | Future Plan |
|---|---|---|
| SOS / Emergency contact API | `notifyFamilyMember()` sends a local push; real SMS requires Firebase Cloud Functions | Integrate Twilio SMS via Cloud Functions trigger |
| Apple / Google Sign-In | Buttons present in UI; OAuth flow not wired | Add `AuthenticationServices` + Google Sign-In SDK |
| Delete Account API | Confirmation dialog exists; Auth + Firestore deletion complete, Storage cleanup pending | Add `StorageReference.delete()` sweep on account deletion |
| Map region | Seeded with Colombo, Sri Lanka coordinates; region configurable via `MockDataProvider` | Detect user country at onboarding and seed region-appropriate mock data |
| Jitsi Meet rooms | Room names generated from session IDs; meet.jit.si public server used | Production: self-hosted Jitsi or 8x8.vc API key for branded rooms |
| Child Mode | PIN-gated parent panel implemented; content filtering rules are a future enhancement | Add `SKAdNetworkConversionValue` and content category tagging per session |
| Conversation ordering | `lastMessageTime` stored as formatted String; ordering is lexicographic | Migrate to Firestore `Timestamp` field for correct chronological ordering |

---

## Student Details

| Field | Detail |
|---|---|
| Student Name | M.S.F.Shazna |
| Student ID | COBSCCOMP24.2P-019 |
| Module | Mobile Application Development — CW2 |
| Institution | NIBM / Coventry University |
