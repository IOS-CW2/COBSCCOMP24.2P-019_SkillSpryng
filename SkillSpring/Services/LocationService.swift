// SIMULATOR TESTING:
// 1. Run app in Simulator
// 2. Xcode menu: Debug → Simulate Location
// 3. Select Custom Location
// 4. Enter: Latitude 6.9271, Longitude 79.8612
//    (Colombo, Sri Lanka)
// 5. For geofence testing: use GeofenceService
//    .shared.simulateGeofenceExit() DEBUG function
// 6. Test permission denied by going to:
//    Simulator Settings → Privacy → Location Services
//    → SkillSpryng → Never

import Foundation
import CoreLocation
import Combine

/// Manages all user location needs for SkillSpryng.
///
/// Privacy-first design:
/// - Uses `kCLLocationAccuracyThreeKilometers` — neighbourhood-level only,
///   never captures exact address.
/// - Stops GPS updates after the first valid reading to conserve battery.
/// - `requestAlwaysPermission()` shows a pre-explanation alert BEFORE
///   prompting iOS, so users understand why background access is needed.
class LocationService: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = LocationService()

    // MARK: - Published State

    /// Most recent valid user location (accuracy ≤ 5000m).
    @Published var userLocation: CLLocation?

    /// Human-readable city/area name from reverse geocoding, e.g. "Colombo".
    /// Never returns a street address.
    @Published var approximateCity: String = ""

    /// Current Core Location authorization status.
    @Published var authorizationStatus: CLAuthorizationStatus

    /// `true` when the user has permanently denied location access.
    /// Drives PermissionDeniedView in MapSelectionView and DiscoverView.
    @Published var locationDenied: Bool = false

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    // MARK: - Init

    private override init() {
        authorizationStatus = CLLocationManager().authorizationStatus
        super.init()
        locationManager.delegate = self
        // Neighbourhood-level accuracy — protects user privacy as per spec
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    // MARK: - Public API

    /// Request foreground location permission.
    /// Use this for discovery feed and map view.
    func requestWhenInUsePermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Request background (Always) location permission.
    /// ONLY call this when an in-person session is about to start.
    /// Shows a user-facing explanation before triggering the iOS prompt.
    ///
    /// - Parameter onGranted: Called once the user taps "Allow" in the explanation alert.
    ///   The caller should present the alert UI and call this when confirmed.
    func requestAlwaysPermission() {
        // Note: The pre-explanation alert is shown by the caller (MapSelectionView)
        // before this function is called. See MapSelectionView.startSafetyMonitoring().
        locationManager.requestAlwaysAuthorization()
    }

    /// Start GPS updates. Stops automatically after the first valid location.
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Stop all GPS updates. Call when location data is no longer needed.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// Deep-links to SkillSpryng's Location settings when the user has permanently denied access.
    /// Call this after showing PermissionDeniedView with type: .location.
    func openSettingsForLocation() {
        openAppSettings()   // defined in AccessibilityHelper.swift
    }

    /// Reverse-geocode a CLLocation into a city/area name.
    ///
    /// - Returns: A city name like "Colombo", never a full address.
    func reverseGeocode(location: CLLocation) async -> String {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                // Return locality (city), fall back to sub-area, then country
                return placemark.locality
                    ?? placemark.subAdministrativeArea
                    ?? placemark.country
                    ?? "Nearby"
            }
        } catch {
            print("[LocationService] Reverse geocode failed: \(error.localizedDescription)")
        }
        return "Colombo" // Fallback for Sri Lanka users
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Ignore readings that are too inaccurate (e.g. initial cached position)
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 5000 else {
            print("[LocationService] Ignoring inaccurate reading: \(location.horizontalAccuracy)m")
            return
        }

        Task { @MainActor in
            self.userLocation = location

            // Reverse geocode to get city name (never full address)
            self.approximateCity = await self.reverseGeocode(location: location)

            // Stop updating — we only need location once for map centering
            self.locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationService] Failed: \(error.localizedDescription)")

        // Do not crash — set a sensible fallback for Sri Lanka users
        if userLocation == nil {
            Task { @MainActor in
                // Colombo, Sri Lanka fallback
                self.userLocation = CLLocation(latitude: 6.9271, longitude: 79.8612)
                self.approximateCity = "Colombo"
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus

            let denied = manager.authorizationStatus == .denied
                      || manager.authorizationStatus == .restricted
            self.locationDenied = denied

            if denied {
                self.userLocation   = nil
                self.approximateCity = ""
                print("[LocationService] ⚠️ Location denied — show PermissionDeniedView(.location)")
            }
        }
    }
}
