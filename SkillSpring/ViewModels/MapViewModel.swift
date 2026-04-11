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
    
    var name: String { profile.fullName }
    var skills: String { profile.skillsToTeach.prefix(2).joined(separator: ", ") }
}

// MARK: - MapViewModel

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Colombo, Sri Lanka
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @Published var locationName: String = "Finding location..."
    @Published var nearbySkills: [SkillLocation] = []
    @Published var isLoadingPins: Bool = false
    @Published var selectedSkill: SkillLocation? = nil
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
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
        print("Location error: \(error.localizedDescription)")
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
                print("Reverse geocode failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Forward Geocode (location string → real coordinates)
    
    /// Converts each MatchProfile's location string into real map coordinates.
    /// CLGeocoder rate-limits concurrent requests, so we process with a small delay.
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
                print("Geocode failed for '\(profile.location)': \(error.localizedDescription)")
            }
            
            // Apple recommends a small delay between geocoding requests to avoid throttling
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        }
        
        isLoadingPins = false
    }
}

