import Foundation
import CoreLocation
import UserNotifications
import Combine

/// Manages geofence monitoring for in-person sessions.
///
/// How it works:
/// 1. When an in-person session starts, call `startMonitoring(sessionTitle:coordinate:radius:)`
/// 2. iOS registers a CLCircularRegion and watches the boundary in the background
/// 3. If the device crosses outside the radius → `didExitRegion` fires → local notification sent
/// 4. When the session ends, call `stopMonitoring()` to deregister the fence
///
/// Requires: NSLocationWhenInUseUsageDescription (works for foreground + suspended)
///           NSLocationAlwaysUsageDescription (required for true background monitoring)
@MainActor
class GeofenceManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = GeofenceManager()
    
    // MARK: - Published State
    
    @Published var isMonitoring: Bool = false
    @Published var userLeftSession: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Private
    
    private let locationManager = CLLocationManager()
    private var activeRegionIdentifier: String?
    private var activeSessionTitle: String = ""
    
    /// Geofence radius in metres. 100m is a good minimum — smaller becomes inaccurate.
    private let defaultRadius: CLLocationDistance = 100
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public API
    
    /// Start monitoring a circular geofence around the session venue.
    /// - Parameters:
    ///   - sessionTitle: shown in the exit notification
    ///   - coordinate: centre of the venue (lat/lng)
    ///   - radius: radius in metres (default 100m)
    func startMonitoring(
        sessionTitle: String,
        coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance? = nil
    ) {
        // Request Always auth for true background monitoring
        locationManager.requestAlwaysAuthorization()
        
        let fenceRadius = radius ?? defaultRadius
        let identifier = "skillspryng.session.\(UUID().uuidString)"
        
        let region = CLCircularRegion(
            center: coordinate,
            radius: fenceRadius,
            identifier: identifier
        )
        region.notifyOnExit  = true   // alert when leaving
        region.notifyOnEntry = false  // we don't need entry events here
        
        // iOS supports up to 20 simultaneous geofences per app
        locationManager.startMonitoring(for: region)
        
        activeRegionIdentifier = identifier
        activeSessionTitle = sessionTitle
        isMonitoring = true
        userLeftSession = false
        
        print("Geofence started: \(sessionTitle) at \(coordinate), radius \(fenceRadius)m")
    }
    
    /// Stop all active geofence monitoring (call when session ends).
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        activeRegionIdentifier = nil
        isMonitoring = false
        userLeftSession = false
        print("Geofence monitoring stopped.")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Task { @MainActor in
            guard region.identifier == self.activeRegionIdentifier else { return }
            self.userLeftSession = true
            self.fireExitNotification()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            guard region.identifier == self.activeRegionIdentifier else { return }
            if self.userLeftSession {
                self.userLeftSession = false
                self.fireReturnNotification()
            }
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofence monitoring failed for \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }
    
    // MARK: - Notifications
    
    private func fireExitNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You've left the session area ⚠️"
        content.body  = "You moved away from your \(activeSessionTitle) venue. Your instructor has been notified."
        content.sound = .defaultCritical
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "geofence.exit.\(activeRegionIdentifier ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Geofence exit notification failed: \(error)") }
        }
        
        HapticManager.warning()
    }
    
    private func fireReturnNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Welcome back! 👋"
        content.body  = "You've returned to the \(activeSessionTitle) venue."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "geofence.return.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
