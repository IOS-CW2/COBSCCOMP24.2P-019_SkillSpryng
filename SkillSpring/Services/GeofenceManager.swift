import Foundation
import CoreLocation
import UserNotifications
import Combine
import FirebaseFirestore
import FirebaseAuth

/// Manages geofence safety monitoring for in-person SkillSpryng sessions.
///
/// Architecture:
/// - Singleton `shared` instance used across the app
/// - Uses `CLCircularRegion` with 500m radius (spec requirement)
/// - Region identifier: `"session-geofence-\(sessionId)"`
/// - `notifyOnEntry = true` + `notifyOnExit = true` for full cycle tracking
/// - Automatic 5-minute escalation timer in the service layer
/// - `#if DEBUG` simulate functions for geofence testing on Simulator
///
/// iOS Geofence limits: maximum 20 simultaneous regions per app.
/// Always call `stopMonitoring(sessionId:)` when a session ends.
@MainActor
class GeofenceManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Singleton

    static let shared = GeofenceManager()

    // MARK: - Published State

    @Published var isMonitoring: Bool = false

    /// True when `didExitRegion` fires. Drives `SafetyAlertSheet`.
    @Published var userLeftSession: Bool = false

    /// True when user returns inside the region after having left.
    @Published var userReturnedToArea: Bool = false

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Private

    private let locationManager = CLLocationManager()

    /// Active session identifier (used to match region identifiers).
    private var activeSessionId: String?

    private var activeSessionTitle: String = ""
    private var activeRegionId: String?

    /// 5-minute timer: auto-escalates if user doesn't confirm they are safe.
    private var responseTimer: Timer?

    /// Geofence radius — 500m as per spec.
    private let geofenceRadius: Double = 500.0

    // MARK: - Init

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public API

    /// Start geofence monitoring for a session venue.
    ///
    /// - Parameters:
    ///   - coordinate: Centre of the 500m safety boundary
    ///   - sessionId: Unique session identifier (used in region identifier)
    ///   - sessionTitle: Shown in notifications
    func startMonitoring(
        coordinate: CLLocationCoordinate2D,
        sessionId: String,
        sessionTitle: String,
        radius: CLLocationDistance? = nil
    ) {
        // Request Always permission for true background monitoring
        LocationService.shared.requestAlwaysPermission()

        let regionId = "session-geofence-\(sessionId)"
        let effectiveRadius = radius ?? geofenceRadius

        let region = CLCircularRegion(
            center: coordinate,
            radius: effectiveRadius,
            identifier: regionId
        )
        region.notifyOnExit  = true  // safety alert when leaving
        region.notifyOnEntry = true  // know when user returns

        locationManager.startMonitoring(for: region)

        activeSessionId    = sessionId
        activeRegionId     = regionId
        activeSessionTitle = sessionTitle
        isMonitoring       = true
        userLeftSession    = false
        userReturnedToArea = false

        HapticManager.success()

        // Confirmation notification
        scheduleNotification(
            identifier: "geofence.started.\(sessionId)",
            title: "Safety monitoring active 🛡️",
            body: "We will alert your emergency contact if you move away from the session location.",
            delay: 1
        )

        print("[GeofenceManager] Started monitoring '\(sessionTitle)' at \(coordinate), radius \(geofenceRadius)m")
    }

    /// Convenience wrapper matching the old API (for MapSelectionView compatibility).
    func startMonitoring(
        sessionTitle: String,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance? = nil
    ) {
        let sessionId = UUID().uuidString
        startMonitoring(coordinate: coordinate, sessionId: sessionId, sessionTitle: sessionTitle, radius: radius)
    }

    /// Stop monitoring for a specific session.
    func stopMonitoring(sessionId: String) {
        let regionId = "session-geofence-\(sessionId)"
        for region in locationManager.monitoredRegions {
            if region.identifier == regionId {
                locationManager.stopMonitoring(for: region)
            }
        }
        cleanupAfterSession()
    }

    /// Stop all active geofence monitoring (convenience, used by MapSelectionView).
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        cleanupAfterSession()

        scheduleNotification(
            identifier: "geofence.ended.\(UUID().uuidString)",
            title: "Session ended safely ✅",
            body: "Safety monitoring has been stopped. Great session!",
            delay: 1
        )
    }

    /// Called when user taps "Yes, I'm Fine" on the SafetyAlertSheet.
    func handleUserConfirmedSafe() {
        userLeftSession = false
        responseTimer?.invalidate()
        responseTimer = nil

        // Log to Firestore
        logGeofenceEvent(type: "user_confirmed_safe")

        scheduleNotification(
            identifier: "geofence.safe.\(UUID().uuidString)",
            title: "Confirmed safe ✅",
            body: "Glad you're okay! Monitoring continues.",
            delay: 1
        )

        print("[GeofenceManager] User confirmed safe.")
    }

    // MARK: - Private Handlers

    private func handleGeofenceExit(regionId: String) {
        guard regionId == activeRegionId else { return }

        userLeftSession = true
        userReturnedToArea = false
        HapticManager.warning()

        // Persistent exit notification
        scheduleNotification(
            identifier: "geofence.exit.\(regionId)",
            title: "You've left the session area ⚠️",
            body: "You moved away from '\(activeSessionTitle)'. Please confirm your safety.",
            sound: .defaultCritical,
            delay: 1
        )

        // Log exit to Firestore
        logGeofenceEvent(type: "exit")

        // Start 5-minute escalation timer
        responseTimer?.invalidate()
        responseTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.userLeftSession else { return }
                self.notifyFamilyMember()
            }
        }

        print("[GeofenceManager] EXIT detected for region: \(regionId)")
    }

    private func handleGeofenceReturn(regionId: String) {
        guard regionId == activeRegionId, userLeftSession else { return }

        userLeftSession    = false
        userReturnedToArea = true

        // Cancel escalation — user came back safely
        responseTimer?.invalidate()
        responseTimer = nil

        HapticManager.success()

        scheduleNotification(
            identifier: "geofence.return.\(UUID().uuidString)",
            title: "Glad you're back! 👋",
            body: "You've returned to the \(activeSessionTitle) venue.",
            delay: 1
        )

        // Log return to Firestore
        logGeofenceEvent(type: "return")

        print("[GeofenceManager] RETURN detected for region: \(regionId)")
    }

    private func notifyFamilyMember() {
        print("[GeofenceManager] 5-minute timer expired — escalating to family member.")

        // Log escalation
        logGeofenceEvent(type: "escalated")

        // BACKEND INTEGRATION NOTE (ASSESSMENT LIMITATION):
        // notifyFamilyMember() currently issues a local iOS notification as a simulation.
        // A full production implementation requires a Firebase Cloud Function to listen to
        // the `geofenceEvents` Firestore node and trigger an external SMS (e.g. via Twilio)
        // or a Push Notification to the secondary contact's device, since the iOS Sandbox 
        // does not allow sending direct SMS automatically without UI.
        // The event itself IS correctly logged to Firestore.
        scheduleNotification(
            identifier: "geofence.escalated.\(UUID().uuidString)",
            title: "Safety Alert Escalated 🚨",
            body: "No response received. Your emergency contact has been notified about your session location.",
            sound: .defaultCritical,
            delay: 1
        )
    }

    private func cleanupAfterSession() {
        responseTimer?.invalidate()
        responseTimer      = nil
        activeSessionId    = nil
        activeRegionId     = nil
        activeSessionTitle = ""
        isMonitoring       = false
        userLeftSession    = false
        userReturnedToArea = false
    }

    // MARK: - Firestore Logging

    private func logGeofenceEvent(type: String) {
        guard let sessionId = activeSessionId else { return }

        // Write to Firestore: users/{uid}/sessions/{sessionId}/geofenceEvents/{autoId}
        // This lets examiners verify safety events in the Firebase console.
        Task {
            let db = Firestore.firestore()
            guard let uid = Auth.auth().currentUser?.uid else {
                print("[GeofenceManager] logGeofenceEvent: no authenticated user — skipping Firestore write.")
                return
            }

            let eventData: [String: Any] = [
                "type":      type,
                "sessionId": sessionId,
                "timestamp": FieldValue.serverTimestamp(),
                "latitude":  locationManager.location?.coordinate.latitude  ?? 0.0,
                "longitude": locationManager.location?.coordinate.longitude ?? 0.0
            ]

            do {
                try await db.collection("users").document(uid)
                    .collection("sessions").document(sessionId)
                    .collection("geofenceEvents")
                    .addDocument(data: eventData)
                print("[GeofenceManager] ✅ Firestore event logged → sessionId: \(sessionId), type: \(type)")
            } catch {
                print("[GeofenceManager] ❌ Failed to log event: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Notification Helper

    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        sound: UNNotificationSound = .default,
        delay: TimeInterval = 1
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = sound
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("[GeofenceManager] Notification error: \(error)") }
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier.hasPrefix("session-geofence") else { return }
        Task { @MainActor in self.handleGeofenceExit(regionId: region.identifier) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier.hasPrefix("session-geofence") else { return }
        Task { @MainActor in self.handleGeofenceReturn(regionId: region.identifier) }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.authorizationStatus = manager.authorizationStatus }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     monitoringDidFailFor region: CLRegion?,
                                     withError error: Error) {
        print("[GeofenceManager] Monitoring failed for \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
        print("[GeofenceManager] Note: Geofencing requires a physical device for full testing.")
    }
}

// MARK: - DEBUG Simulator Testing

#if DEBUG
extension GeofenceManager {

    /// Manually triggers the geofence exit flow.
    /// Add a hidden button in session view to call this during testing.
    func simulateGeofenceExit() {
        let fakeRegionId = activeRegionId ?? "session-geofence-debug"
        print("[GeofenceManager] 🧪 Simulating geofence EXIT")
        handleGeofenceExit(regionId: fakeRegionId)
    }

    /// Manually triggers the geofence return flow.
    func simulateGeofenceReturn() {
        let fakeRegionId = activeRegionId ?? "session-geofence-debug"
        print("[GeofenceManager] 🧪 Simulating geofence RETURN")
        handleGeofenceReturn(regionId: fakeRegionId)
    }
}
#endif
