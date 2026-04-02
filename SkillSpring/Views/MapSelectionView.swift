import SwiftUI
import MapKit

struct MapSelectionView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7892, longitude: -122.3965), // San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Mock annotations from screen
    let annotations = [
        MapPoint(name: "Tennis Coach", coordinate: CLLocationCoordinate2D(latitude: 37.7895, longitude: -122.4000), icon: "figure.tennis"),
        MapPoint(name: "UX Workshop", coordinate: CLLocationCoordinate2D(latitude: 37.7885, longitude: -122.3960), icon: "desktopcomputer")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map(coordinateRegion: $region, annotationItems: annotations) { point in
                MapAnnotation(coordinate: point.coordinate) {
                    MapPointView(point: point)
                }
            }
            .ignoresSafeArea()
            
            // Map Controls (Overlay)
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
            
            // Pick Session Point Card
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("PICK SESSION POINT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Text("Salesforce Transit Center")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("425 Mission St, San Francisco, CA")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 16) {
                    AmenityView(icon: "wifi", title: "Fast WiFi")
                    AmenityView(icon: "cup.and.saucer.fill", title: "Quiet Cafe", color: .orange)
                }
                
                PrimaryButton(title: "Confirm Meeting Location ->") {
                    // Confirm action
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.1), radius: 20)
            .padding()
        }
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
