import Foundation
import MapKit
import Combine
import CoreLocation

// MARK: - SkillLocation Model

/// A map annotation backed by a real MatchProfile.
struct SkillLocation: Identifiable {
    let id = UUID()
    let profile: MatchProfile
    let coordinate: CLLocationCoordinate2D

    var name: String    { profile.fullName }
    var skills: String  { profile.skillsToTeach.prefix(2).joined(separator: ", ") }
}

// MARK: - MapViewModel

/// Manages the Discover map view and nearby skill pins.
///
/// Tracks current region, location permissions, reverse geocoded city name,
/// and geocodes instructor profiles into map annotations.
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published State

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Colombo, Sri Lanka
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    /// Human-readable city name from reverse geocoding.
    @Published var locationName: String = "Finding location..."

    /// Also exposed as `approximateCity` to match the spec property name.
    var approximateCity: String { locationName }

    @Published var nearbySkills: [SkillLocation] = []
    @Published var isLoadingPins: Bool = false
    @Published var selectedSkill: SkillLocation? = nil
    @Published var currentUser: User?

    /// Observable authorization status for the permission-denied UI state.
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        permissionStatus = locationManager.authorizationStatus
        // Geocode profiles immediately using default region until GPS fix
        Task { await geocodeProfiles() }
    }

    // MARK: - Location Permission & GPS

    /// Requests foreground location permission and begins updating location.
    /// Used by the map screen to center on the user's current region.
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
            self.fetchCityName(for: location)
            self.locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[MapViewModel] Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.permissionStatus = manager.authorizationStatus
        }
    }

    // MARK: - Reverse Geocode (city name from GPS)

    /// Updates the city label for the map using the current GPS location.
    @MainActor
    private func fetchCityName(for location: CLLocation) {
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    self.locationName = placemark.locality ?? "Current Location"
                }
            } catch {
                print("[MapViewModel] Reverse geocode failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Forward Geocode (location string → real coordinates)

    /// Refreshes the nearby skill pins by loading profiles and geocoding their locations.
    @MainActor
    func loadNearbyUsers() async {
        self.currentUser = await FirebaseDataService.shared.fetchCurrentUser()
        await geocodeProfiles()
    }

    /// Converts profile address strings into map annotations.
    /// Uses a small delay between requests to avoid CLGeocoder throttling.
    @MainActor
    func geocodeProfiles() async {
        isLoadingPins = true
        nearbySkills = []

        let profiles = await FirebaseDataService.shared.fetchProfiles()

        for profile in profiles {
            // Skip "Online" profiles — they have no physical location
            guard profile.location.lowercased() != "online",
                  !profile.location.isEmpty else { continue }

            do {
                let placemarks = try await geocoder.geocodeAddressString(profile.location)
                if let coordinate = placemarks.first?.location?.coordinate {
                    let pin = SkillLocation(profile: profile, coordinate: coordinate)
                    self.nearbySkills.append(pin)
                }
            } catch {
                // CLGeocoder can rate-limit — log and skip gracefully
                print("[MapViewModel] Geocode failed for '\(profile.location)': \(error.localizedDescription)")
            }

            // Apple recommends a small delay between geocoding requests to avoid throttling
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        }

        isLoadingPins = false
    }

    // MARK: - Distance Calculation

    /// Returns a formatted walking/driving distance string to a profile.
    /// Falls back to the profile's stored distance string if GPS is unavailable.
    func calculateDistance(to profile: MatchProfile) -> String {
        guard let userLocation = LocationService.shared.userLocation else {
            return profile.distance // Fall back to the static string in the profile
        }

        // Find the geocoded SkillLocation for this profile
        guard let skillLocation = nearbySkills.first(where: { $0.profile.id == profile.id }) else {
            return profile.distance
        }

        let targetLocation = CLLocation(
            latitude: skillLocation.coordinate.latitude,
            longitude: skillLocation.coordinate.longitude
        )

        let distanceMetres = userLocation.distance(from: targetLocation)

        if distanceMetres < 1000 {
            return "\(Int(distanceMetres)) m"
        } else {
            let km = distanceMetres / 1000.0
            return String(format: "%.1f km", km)
        }
    }

    /// Calculates a skills match score between the current user and a profile.
    /// This score is based on mutual teach/learn overlap and is capped at 100%.
    func calculateMatchPercentage(with profile: MatchProfile) -> Int {
        guard let currentUser = self.currentUser else { return 0 }

        let iCanTeachWhatTheyLearn = Set(currentUser.skillsToTeach)
            .intersection(Set(profile.skillsToLearn))

        let theyCanTeachWhatILearn = Set(profile.skillsToTeach)
            .intersection(Set(currentUser.skillsToLearn))

        let totalMatches = iCanTeachWhatTheyLearn.count + theyCanTeachWhatILearn.count
        let totalSkills  = max(currentUser.skillsToTeach.count + currentUser.skillsToLearn.count, 1)

        let percentage = Int((Double(totalMatches) / Double(totalSkills)) * 100)
        return min(max(percentage, 0), 100)
    }
}
