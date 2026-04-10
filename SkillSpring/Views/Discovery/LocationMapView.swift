import SwiftUI
import MapKit

struct LocationMapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby Skills")
                    .font(.title2)
                    .bold()
                Spacer()
                Text(viewModel.locationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.nearbySkills) { skill in
                MapMarker(coordinate: skill.coordinate, tint: .green)
            }
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {
                viewModel.requestPermission()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Use My Current Location")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(12)
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            // Optional: Request permission immediately or let user tap the button
        }
    }
}

#Preview {
    LocationMapView()
}
