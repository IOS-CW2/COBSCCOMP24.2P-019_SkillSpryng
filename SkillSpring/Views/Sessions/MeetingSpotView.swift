import SwiftUI
import MapKit
import CoreLocation

// MARK: - Meeting Spot Model

struct MeetingSpot: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let categoryIcon: String
    let coordinate: CLLocationCoordinate2D
    let approximateDistance: String
}

// MARK: - Mock Data for Simulator

#if DEBUG
private let mockMeetingSpots: [MeetingSpot] = [
    MeetingSpot(
        name: "Colombo Public Library",
        category: "Public Library",
        categoryIcon: "books.vertical.fill",
        coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8572),
        approximateDistance: "0.5 km"
    ),
    MeetingSpot(
        name: "Coffee Lounge",
        category: "Quiet Café",
        categoryIcon: "cup.and.saucer.fill",
        coordinate: CLLocationCoordinate2D(latitude: 6.9295, longitude: 79.8631),
        approximateDistance: "1.1 km"
    ),
    MeetingSpot(
        name: "Viharamahadevi Community Hall",
        category: "Community Centre",
        categoryIcon: "building.2.fill",
        coordinate: CLLocationCoordinate2D(latitude: 6.9185, longitude: 79.8620),
        approximateDistance: "1.7 km"
    ),
    MeetingSpot(
        name: "Crescat Café",
        category: "Quiet Café",
        categoryIcon: "cup.and.saucer.fill",
        coordinate: CLLocationCoordinate2D(latitude: 6.9152, longitude: 79.8502),
        approximateDistance: "2.0 km"
    )
]
#endif

// MARK: - MeetingSpotView

struct MeetingSpotView: View {

    /// Called when the user selects a meeting spot.
    var onSpotSelected: (MeetingSpot) -> Void

    @State private var spots: [MeetingSpot] = []
    @State private var isLoading = false
    @State private var selectedSpot: MeetingSpot? = nil
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "Choose Meeting Spot", backAction: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // Subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Safe Public Venues")
                            .font(AppTheme.Typography.title2)
                        Text("We suggest public libraries, cafés, and community centres within 2km of your location.")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Mini Map — 160pt height
                    ZStack {
                        Map(coordinateRegion: $mapRegion, annotationItems: spots) { spot in
                            MapAnnotation(coordinate: spot.coordinate) {
                                VStack(spacing: 0) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedSpot?.id == spot.id
                                                  ? AppTheme.Colors.primary
                                                  : AppTheme.Colors.primary)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: spot.categoryIcon)
                                            .font(AppTheme.Typography.footnote)
                                            .foregroundColor(.white)
                                    }
                                    .accessibilityHidden(true)
                                    Image(systemName: "arrowtriangle.down.fill")
                                        .font(AppTheme.Typography.caption2)
                                        .foregroundColor(selectedSpot?.id == spot.id
                                                         ? AppTheme.Colors.primary : .green)
                                        .offset(y: -2)
                                }
                                .onTapGesture { selectedSpot = spot }
                            }
                        }
                        .frame(height: 160)
                        .cornerRadius(16)

                        if isLoading {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.black.opacity(0.3))
                                .frame(height: 160)
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .padding(.horizontal)

                    // "Approximate locations" privacy note
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.green)
                        Text("Approximate venue locations only. Your exact address is never shared.")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)

                    // Horizontal scroll cards
                    if spots.isEmpty && !isLoading {
                        Text("No public venues found nearby. Try on a physical device.")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(spots) { spot in
                                    MeetingSpotCard(
                                        spot: spot,
                                        isSelected: selectedSpot?.id == spot.id
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedSpot = spot
                                            // Centre map on selected spot
                                            mapRegion.center = spot.coordinate
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }

                    // Confirm button
                    if let spot = selectedSpot {
                        Button(action: {
                            onSpotSelected(spot)
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Set '\(spot.name)' as Venue")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { loadVenues() }
    }

    // MARK: - Load Venues

    private func loadVenues() {
        isLoading = true

        #if DEBUG
        // Use hardcoded mock data for Simulator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            spots = mockMeetingSpots
            isLoading = false
        }
        #else
        // Real device: use MKLocalSearch to find public venues within 2km
        searchNearbyVenues()
        #endif
    }

    private func searchNearbyVenues() {
        let userCoord = LocationService.shared.userLocation?.coordinate
            ?? CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)

        let searchRadius: CLLocationDistance = 2000 // 2km

        let queries = ["public library", "coffee shop", "community centre"]
        var allSpots: [MeetingSpot] = []
        let group = DispatchGroup()

        mapRegion = MKCoordinateRegion(
            center: userCoord,
            latitudinalMeters: searchRadius * 2,
            longitudinalMeters: searchRadius * 2
        )

        for query in queries {
            group.enter()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = mapRegion

            MKLocalSearch(request: request).start { response, _ in
                defer { group.leave() }
                guard let items = response?.mapItems else { return }

                let filtered = items.prefix(2).compactMap { item -> MeetingSpot? in
                    guard let coord = item.placemark.location?.coordinate else { return nil }
                    let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
                    let spotLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    let dist = userLoc.distance(from: spotLoc)
                    guard dist <= searchRadius else { return nil }

                    let distStr = dist < 1000
                        ? "\(Int(dist)) m"
                        : String(format: "%.1f km", dist / 1000)

                    let (icon, cat) = categoryInfo(for: query)
                    return MeetingSpot(
                        name: item.name ?? query.capitalized,
                        category: cat,
                        categoryIcon: icon,
                        coordinate: coord,
                        approximateDistance: distStr
                    )
                }

                allSpots.append(contentsOf: filtered)
            }
        }

        group.notify(queue: .main) {
            spots = allSpots
            isLoading = false
        }
    }

    private func categoryInfo(for query: String) -> (String, String) {
        switch query {
        case "public library":   return ("books.vertical.fill", "Public Library")
        case "coffee shop":      return ("cup.and.saucer.fill", "Quiet Café")
        case "community centre": return ("building.2.fill",     "Community Centre")
        default:                 return ("mappin.fill",          query.capitalized)
        }
    }
}

// MARK: - Meeting Spot Card

struct MeetingSpotCard: View {
    let spot: MeetingSpot
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? AppTheme.Colors.primary.opacity(0.15)
                          : AppTheme.Colors.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: spot.categoryIcon)
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(isSelected ? AppTheme.Colors.primary : .green)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(AppTheme.Typography.subheadline)
                    .lineLimit(2)
                Text(spot.category)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.Colors.primary)
                Text(spot.approximateDistance)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(AppTheme.Colors.primary)
            }

            Button(action: onSelect) {
                Text(isSelected ? "Selected ✓" : "Select")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(9)
            }
        }
        .padding(14)
        .frame(width: 160)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: isSelected
                ? AppTheme.Colors.primary.opacity(0.2)
                : Color.black.opacity(0.06),
                radius: isSelected ? 12 : 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
        )
        .animation(.spring(response: 0.25), value: isSelected)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(spot.name), \(spot.category). Distance: \(spot.approximateDistance)")
    }
}
