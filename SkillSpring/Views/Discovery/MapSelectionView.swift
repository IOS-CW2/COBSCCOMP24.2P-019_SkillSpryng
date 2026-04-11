import SwiftUI
import MapKit
import CoreLocation

struct MapSelectionView: View {
    var session: Session? = nil
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Colombo default
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var venueCoordinate: CLLocationCoordinate2D? = nil
    @StateObject private var geofenceManager = GeofenceManager.shared
    @State private var showMonitoringStarted = false
    
    // Mock annotations from screen
    let annotations = [
        MapPoint(name: "Tennis Coach", coordinate: CLLocationCoordinate2D(latitude: 37.7895, longitude: -122.4000), icon: "figure.tennis"),
        MapPoint(name: "UX Workshop", coordinate: CLLocationCoordinate2D(latitude: 37.7885, longitude: -122.3960), icon: "desktopcomputer")
    ]
    
    var venueAnnotations: [MapPoint] {
        guard let coord = venueCoordinate else { return annotations }
        return [MapPoint(name: session?.location ?? "Session Venue", coordinate: coord, icon: "mappin.circle.fill")]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: venueAnnotations) { point in
                MapAnnotation(coordinate: point.coordinate) {
                    MapPointView(point: point)
                }
            }
            .ignoresSafeArea()
            
            // Map Controls
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        MapButton(icon: "scope")
                        MapButton(icon: "layers.fill")
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Bottom Card
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("SESSION VENUE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                        Spacer()
                        if geofenceManager.isMonitoring {
                            HStack(spacing: 4) {
                                Circle().fill(Color.green).frame(width: 6, height: 6)
                                Text("MONITORING ACTIVE")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(session?.location ?? "Salesforce Transit Center")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(session?.title ?? "Session")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 16) {
                    AmenityView(icon: "wifi", title: "Fast WiFi")
                    AmenityView(icon: "cup.and.saucer.fill", title: "Quiet Cafe", color: .orange)
                }
                
                if geofenceManager.isMonitoring {
                    // Already monitoring
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                        Text("Safety monitoring is active")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    Button("Stop Monitoring") {
                        geofenceManager.stopMonitoring()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                    
                } else {
                    // Start monitoring on arrival
                    Button(action: startSafetyMonitoring) {
                        HStack {
                            Image(systemName: "shield.fill")
                            Text("I've Arrived — Start Safety Monitoring")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.1), radius: 20)
            .padding()
        }
        .navigationBarHidden(false)
        .onAppear {
            geocodeVenue()
        }
        .alert("Safety Monitoring Started", isPresented: $showMonitoringStarted) {
            Button("Got It", role: .cancel) { }
        } message: {
            Text("You'll be notified if you move more than 100m from the venue during your session.")
        }
    }
    
    // MARK: - Helpers
    
    private func geocodeVenue() {
        guard let address = session?.location else { return }
        Task {
            let geocoder = CLGeocoder()
            if let placemark = try? await geocoder.geocodeAddressString(address),
               let coord = placemark.first?.location?.coordinate {
                await MainActor.run {
                    self.venueCoordinate = coord
                    self.region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                }
            }
        }
    }
    
    private func startSafetyMonitoring() {
        let coord = venueCoordinate ?? region.center
        GeofenceManager.shared.startMonitoring(
            sessionTitle: session?.title ?? "Session",
            coordinate: coord,
            radius: 100
        )
        HapticManager.success()
        showMonitoringStarted = true
    }
}


// Sub-components
struct MapPoint: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
}

struct MapPointView: View {
    let point: MapPoint
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(point.name)
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(6)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 8, height: 4)
                .rotationEffect(.degrees(180))
                .foregroundColor(.white)
        }
    }
}

struct MapButton: View {
    let icon: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}

struct AmenityView: View {
    let icon: String
    let title: String
    var color: Color = .green
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
