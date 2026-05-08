import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Binding var locationText: String

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Select Location")
                    .font(AppTheme.Typography.headline)
                Spacer()
                Button(action: { confirmSelection() }) {
                    Text("Done")
                        .bold()
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))

            ZStack {
                Map(coordinateRegion: $region)
                    .ignoresSafeArea(edges: .horizontal)
                    .frame(height: 420)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                    .offset(y: -24)
                    .shadow(radius: 4)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Drag the map until the pin is over your chosen location.")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.gray)

                Text("Latitude: \(String(format: "%.5f", region.center.latitude))")
                Text("Longitude: \(String(format: "%.5f", region.center.longitude))")
            }
            .padding()

            Spacer()

            Button(action: confirmSelection) {
                Text("Select This Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(18)
            }
            .padding([.horizontal, .bottom])
        }
    }

    private func confirmSelection() {
        selectedCoordinate = region.center
        locationText = "Colombo, Sri Lanka"
        dismiss()
    }
}
