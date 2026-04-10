import Foundation
import MapKit
import Combine
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var locationName: String = "Finding location..."
    
    // Simulate some nearby users offering skills
    @Published var nearbySkills: [SkillLocation] = [
        SkillLocation(name: "John - iOS Dev", coordinate: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4180)),
        SkillLocation(name: "Sarah - Spanish", coordinate: CLLocationCoordinate2D(latitude: 37.7730, longitude: -122.4200))
    ]
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            self.fetchCityName(for: location)
            // Stop updating to save battery if we only need it once
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @MainActor
    private func fetchCityName(for location: CLLocation) {
        let geocoder = CLGeocoder()
        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    self.locationName = placemark.locality ?? "Current Location"
                }
            } catch {
                print("Failed to reverse geocode: \(error.localizedDescription)")
            }
        }
    }
}

struct SkillLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
