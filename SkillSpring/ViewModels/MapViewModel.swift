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

    /// Fetches nearby users (from MockData in DEBUG, Firestore in production)
    /// and geocodes their location strings to map coordinates.
    @MainActor
    func loadNearbyUsers() async {
        await geocodeProfiles()
    }

    /// Converts each MatchProfile's location string into real map coordinates.
    /// CLGeocoder rate-limits concurrent requests, so we process with a 0.3s delay.
    @MainActor
    func geocodeProfiles() async {
        isLoadingPins = true
        nearbySkills = []

        let profiles = MockDataProvider.shared.allProfiles

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

    /// Returns a formatted distance string from the user's current location to a profile.
    /// Returns "Nearby" if user location is unavailable.
    ///
    /// Example: "1.2 km" or "850 m"
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

    /// Calculates a skill-overlap match percentage between the current user and a profile.
    ///
    /// Algorithm:
    /// - Count skills where currentUser.skillsToTeach ∩ targetUser.skillsToLearn
    /// - Count skills where currentUser.skillsToLearn ∩ targetUser.skillsToTeach
    /// - Return (matches / max possible) * 100, clamped to 0–100
    func calculateMatchPercentage(with profile: MatchProfile) -> Int {
        let currentUser = MockDataProvider.shared.currentUser

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
